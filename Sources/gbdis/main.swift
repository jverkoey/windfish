import Foundation
import LR35902

let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"))

let disassembly = LR35902.Disassembly(rom: data)

func extractText(from range: Range<LR35902.CartridgeLocation>) {
  let parts = data[range].split(separator: 0xff, maxSplits: .max, omittingEmptySubsequences: false)
  let addressAndBank = LR35902.addressAndBank(from: range.lowerBound)
  var offset: LR35902.Address = addressAndBank.address
  for (index, part) in parts.enumerated() {
    let textRange = offset..<(offset + LR35902.Address(part.count))
    disassembly.setText(at: textRange, in: addressAndBank.bank, lineLength: 16)
    if index != parts.endIndex {
      disassembly.setData(at: textRange.upperBound, in: addressAndBank.bank)
    }
    offset += LR35902.Address(part.count + 1)
  }
}

func disassembleJumpTable(within range: Range<LR35902.Address>, in bank: LR35902.Bank) {
  // RST $00 invocations are followed by a 2 byte jump address.
  disassembly.setLabel(at: range.lowerBound, in: bank, named: "jumpTable")
  // TODO: Allow data ranges to specify a line length.
  disassembly.setData(at: range, in: bank)

  for location in stride(from: LR35902.cartAddress(for: range.lowerBound, in: bank)!, to: LR35902.cartAddress(for: range.upperBound, in: bank)!, by: 2) {
    let lowByte = data[Int(location)]
    let highByte = data[Int(location + 1)]
    let address: LR35902.Address = (LR35902.Address(highByte) << 8) | LR35902.Address(lowByte)
    let definitionAddress = LR35902.addressAndBank(from: location).address
    disassembly.defineFunction(startingAt: address, in: bank, named: "JumpTable_\(address.hexString)_\(definitionAddress.hexString)")
  }
}

disassembly.createDatatype(named: "GAMEMODE", enumeration: [
  0x00: "GAMEMODE_INTRO",
  0x01: "GAMEMODE_CREDITS",
  0x02: "GAMEMODE_FILE_SELECT",
  0x03: "GAMEMODE_FILE_NEW",
  0x04: "GAMEMODE_FILE_DELETE",
  0x05: "GAMEMODE_FILE_COPY",
  0x06: "GAMEMODE_FILE_SAVE",
  0x07: "GAMEMODE_MINI_MAP",
  0x08: "GAMEMODE_PEACH_PIC",
  0x09: "GAMEMODE_MARIN_BEACH",
  0x0a: "GAMEMODE_WF_MURAL",
  0x0b: "GAMEMODE_WORLD",
  0x0c: "GAMEMODE_INVENTORY",
  0x0d: "GAMEMODE_PHOTO_ALBUM",
  0x0e: "GAMEMODE_PHOTO_DIZZY_LINK",
  0x0f: "GAMEMODE_PHOTO_NICE_LINK",
  0x10: "GAMEMODE_PHOTO_MARIN_CLIFF",
  0x11: "GAMEMODE_PHOTO_MARIN_WELL",
  0x12: "GAMEMODE_PHOTO_MABE",
  0x13: "GAMEMODE_PHOTO_ULRIRA",
  0x14: "GAMEMODE_PHOTO_BOW_WOW",
  0x15: "GAMEMODE_PHOTO_THIEF",
  0x16: "GAMEMODE_PHOTO_FISHERMAN",
  0x17: "GAMEMODE_PHOTO_ZORA",
  0x18: "GAMEMODE_PHOTO_KANALET",
  0x19: "GAMEMODE_PHOTO_GHOST",
  0x20: "GAMEMODE_PHOTO_BRIDGE",
])

disassembly.setData(at: 0x0004..<0x0008, in: 0x00)
disassembly.setData(at: 0x0008..<0x0040, in: 0x00)

disassembly.createGlobal(at: 0x0003, named: "DEBUG_TOOL", dataType: "bool")
disassembly.createGlobal(at: 0xa100, named: "SAVEFILES")
disassembly.createGlobal(at: 0xc124, named: "wRoomTransitionState")
disassembly.createGlobal(at: 0xc125, named: "wRoomTransitionDirection")
disassembly.createGlobal(at: 0xc155, named: "wScreenShakeHorizontal")
disassembly.createGlobal(at: 0xc156, named: "wScreenShakeVertical")
disassembly.createGlobal(at: 0xc1bf, named: "wScrollXOffset")
disassembly.createGlobal(at: 0xc500, named: "wAlternateBackgroundEnabled")
disassembly.createGlobal(at: 0xd369, named: "wAudioData")
disassembly.createGlobal(at: 0xd379, named: "wAudioSelection")
disassembly.createGlobal(at: 0xd6fe, named: "wTileMapToLoad")
disassembly.createGlobal(at: 0xd6ff, named: "wBGMapToLoad")
disassembly.createGlobal(at: 0xdb95, named: "wGameMode", dataType: "GAMEMODE")
disassembly.createGlobal(at: 0xdb96, named: "wGameSubMode")
disassembly.createGlobal(at: 0xdbaf, named: "wCurrentBank")
disassembly.createGlobal(at: 0xff96, named: "hBaseScrollX")
disassembly.createGlobal(at: 0xff97, named: "hBaseScrollY")
disassembly.createGlobal(at: 0xffa9, named: "hWindowY")
disassembly.createGlobal(at: 0xffaa, named: "hWindowX")
disassembly.createGlobal(at: 0xffb5, named: "hButtonsInactiveDelay", dataType: "decimal")
disassembly.createGlobal(at: 0xffe7, named: "hFrameCounter")
disassembly.createGlobal(at: 0xffd1, named: "hNeedsRenderingFrame")
disassembly.createGlobal(at: 0xfff7, named: "hMapID")
disassembly.createGlobal(at: 0xfffd, named: "hDidRenderFrame", dataType: "bool")

disassembly.register(bankChange: 0x01, at: 0x03af, in: 0x00)
disassembly.register(bankChange: 0x01, at: 0x0b50, in: 0x00)
disassembly.register(bankChange: 0x17, at: 0x0b0d, in: 0x00)
//disassembly.register(bankChange: 0x0f, at: 0x0c37, in: 0x00)
//disassembly.register(bankChange: 0x01, at: 0x289d, in: 0x00)
//disassembly.register(bankChange: 0x0c, at: 0x2b70, in: 0x00)
//disassembly.register(bankChange: 0x0c, at: 0x2B81, in: 0x00)
//disassembly.register(bankChange: 0x01, at: 0x2B9E, in: 0x00)

disassembleJumpTable(within: 0x04b3..<0x04F5, in: 0x00)
disassembleJumpTable(within: 0x0ad2..<0x0aea, in: 0x00)

disassembly.disassembleAsGameboyCartridge()

// MARK: - Bank 0 (00)

disassembly.defineFunction(startingAt: 0x0150, in: 0x00, named: "Main")
disassembly.setPreComment(at: 0x0156, in: 0x00, text: "Reset the palette registers to zero.")
disassembly.setPreComment(at: 0x015D, in: 0x00, text: "Clears 6144 bytes of video ram. Graphics vram location for OBJ and BG tiles start at $8000 and end at $97FF; for a total of 0x1800 bytes.")
disassembly.setLabel(at: 0x01a6, in: 0x00, named: "frameDidRender")
disassembly.setPreComment(at: 0x01b7, in: 0x00, text: "Load a with a value that is non-zero every other frame.")
disassembly.setLabel(at: 0x01aa, in: 0x00, named: "Main.renderLoop_setScrollY")
disassembly.setLabel(at: 0x01be, in: 0x00, named: "defaultShakeBehavior")
disassembly.setLabel(at: 0x01c4, in: 0x00, named: "setScrollY")
disassembly.setLabel(at: 0x01f5, in: 0x00, named: "playAudio")
disassembly.setLabel(at: 0x01fb, in: 0x00, named: "skipAudio")
disassembly.setPreComment(at: 0x2872, in: 0x00, text: """
hl = address after rst $00 invocation
hl += [0, a << 1]
hl = [ram[hl + 1], ram[hl]]
jp hl
""")
disassembly.defineFunction(startingAt: 0x2872, in: 0x00, named: "JumpTable")
disassembly.setLabel(at: 0x03bd, in: 0x00, named: "waitForNextFrame")
disassembly.defineFunction(startingAt: 0x04a1, in: 0x00, named: "LoadMapData")
disassembly.setLabel(at: 0x04f5, in: 0x00, named: "loadMapZero")
disassembly.setLabel(at: 0x0516, in: 0x00, named: "cleanupAndReturn")
disassembly.defineFunction(startingAt: 0x07B9, in: 0x00, named: "SetBank")
disassembly.defineFunction(startingAt: 0x0844, in: 0x00, named: "PlayAudioStep")
disassembly.defineFunction(startingAt: 0x2881, in: 0x00, named: "LCDOff")
disassembly.defineFunction(startingAt: 0x28A8, in: 0x00, named: "FillBGWith7F")
disassembly.defineFunction(startingAt: 0x28C5, in: 0x00, named: "CopyMemoryRegion")
disassembly.defineFunction(startingAt: 0x28F2, in: 0x00, named: "CopyBackgroundData")
disassembly.defineFunction(startingAt: 0x298A, in: 0x00, named: "ClearHRAM")
disassembly.defineFunction(startingAt: 0x2999, in: 0x00, named: "ClearMemoryRegion")
disassembly.defineFunction(startingAt: 0x2B6B, in: 0x00, named: "LoadInitialTiles")

// MARK: - Bank 1 (01)
disassembly.defineFunction(startingAt: 0x40CE, in: 0x01, named: "LCDOn")
disassembly.defineFunction(startingAt: 0x46DD, in: 0x01, named: "InitSave")
disassembly.defineFunction(startingAt: 0x460F, in: 0x01, named: "InitSaves")
disassembly.defineFunction(startingAt: 0x7D19, in: 0x01, named: "CopyDMATransferToHRAM")
disassembly.defineFunction(startingAt: 0x7D27, in: 0x01, named: "DMATransfer")

// MARK: - Bank 5 (05)
disassembly.setData(at: 0x5919..<(0x5919 + 0x0010), in: 0x05)
disassembly.setData(at: 0x5939..<(0x5939 + 0x0010), in: 0x05)

// MARK: - Bank 9 (09)
extractText(from: LR35902.cartAddress(for: 0x6700, in: 0x09)!..<LR35902.cartAddress(for: 0x6d9f, in: 0x09)!)
extractText(from: LR35902.cartAddress(for: 0x7d00, in: 0x09)!..<LR35902.cartAddress(for: 0x7eef, in: 0x09)!)

// MARK: - Bank 12 (0c)
disassembly.setData(at: 0x4000..<(0x4000 + 0x0400), in: 0x0c)
disassembly.setData(at: 0x4800..<(0x4800 + 0x1000), in: 0x0c)
disassembly.setData(at: 0x47a0..<(0x47a0 + 0x0020), in: 0x0c)

// MARK: - Bank 20 (14)
extractText(from: LR35902.cartAddress(for: 0x5c00, in: 0x14)!..<LR35902.cartAddress(for: 0x79cd, in: 0x14)!)

// MARK: - Bank 22 (16)
extractText(from: LR35902.cartAddress(for: 0x5700, in: 0x16)!..<LR35902.cartAddress(for: 0x7ff0, in: 0x16)!)

// MARK: - Bank 23 (17)
disassembly.setLabel(at: 0x4099, in: 0x17, named: "CreditsText")
disassembly.setText(at: 0x4099..<0x42fd, in: 0x17)

// MARK: - Bank 27 (1b)
disassembly.defineFunction(startingAt: 0x4006, in: 0x1b, named: "AudioStep1b_Launcher")
disassembly.defineFunction(startingAt: 0x401e, in: 0x1b, named: "AudioStep1b_Start")
disassembly.defineFunction(startingAt: 0x4037, in: 0x1b, named: "CheckAudioSelection")
disassembly.defineFunction(startingAt: 0x42ae, in: 0x1b, named: "CheckAndResetAudio_Variant1")
disassembly.defineFunction(startingAt: 0x40ef, in: 0x1b, named: "CheckAndResetAudio_Variant2")
//disassembly.defineFunction(startingAt: 0x4275, in: 0x1b, named: "SelectAudioTerminals")
//disassembly.defineFunction(startingAt: 0x4392, in: 0x1b, named: "LoadHLIndirectToB")

disassembly.setLabel(at: 0x415d, in: 0x1b, named: "AudioData")
for i in LR35902.Address(0)..<LR35902.Address(32) {
  // TODO: Allow data to be grouped.
  disassembly.setData(at: (0x415d + i * 6)..<(0x415d + (i + 1) * 6), in: 0x1b)
}

// MARK: - Bank 28 (1c)
extractText(from: LR35902.cartAddress(for: 0x4a00, in: 0x1c)!..<LR35902.cartAddress(for: 0x7360, in: 0x1c)!)

// MARK: - Bank 28 (1d)
extractText(from: LR35902.cartAddress(for: 0x4000, in: 0x1d)!..<LR35902.cartAddress(for: 0x7FB6, in: 0x1d)!)

// MARK: - Bank 31 (1f)
disassembly.defineFunction(startingAt: 0x4000, in: 0x1f, named: "EnableSound")
disassembly.defineFunction(startingAt: 0x4006, in: 0x1f, named: "PlayAudioStep_Launcher")
disassembly.setLabel(at: 0x401e, in: 0x1f, named: "PlayAudioStep_Start")

disassembly.defineFunction(startingAt: 0x4204, in: 0x1f, named: "InitSquareSound")
disassembly.setLabel(at: 0x53e6, in: 0x1f, named: "ClearActiveSquareSound")

disassembly.defineFunction(startingAt: 0x53ed, in: 0x1f, named: "InitWaveSound")
disassembly.setLabel(at: 0x6385, in: 0x1f, named: "ClearActiveWaveSound")

disassembly.defineFunction(startingAt: 0x64e8, in: 0x1f, named: "InitNoiseSound")
disassembly.setLabel(at: 0x650e, in: 0x1f, named: "_InitNoiseSoundNoNoiseSound")
disassembly.setLabel(at: 0x7a28, in: 0x1f, named: "ClearActiveNoiseSound")

disassembly.setLabel(at: 0x7a60, in: 0x1f, named: "_ShiftHL")

disassembly.defineFunction(startingAt: 0x7f80, in: 0x1f, named: "SoundUnknown1")


disassembly.defineMacro(named: "changebank", instructions: [
  .any(.ld(.a, .imm8)),
  .instruction(.init(spec: .ld(.imm16addr, .a), imm16: 0x2100)),
], code: [
  .ld(.a, .arg(1)),
  .ld(.imm16addr, .a),
])

disassembly.defineMacro(named: "callcb", instructions: [
  .any(.ld(.a, .imm8)),
  .instruction(.init(spec: .ld(.imm16addr, .a), imm16: 0x2100)),
  .any(.call(nil, .imm16))
], code: [
  .ld(.a, .macro("bank(\\1)")),
  .ld(.imm16addr, .a),
  .call(nil, .arg(1))
], validArgumentValues: [
  1: IndexSet(integersIn: 0x4000..<0x8000)
])

disassembly.defineMacro(named: "copyRegion", instructions: [
  .any(.ld(.hl, .imm16)),
  .any(.ld(.de, .imm16)),
  .any(.ld(.bc, .imm16)),
  .instruction(.init(spec: .call(nil, .imm16), imm16: 0x28C5)),
], code: [
  .ld(.hl, .arg(1)),
  .ld(.de, .arg(3)),
  .ld(.bc, .arg(2)),
  .call(nil, .imm16),
])

disassembly.defineMacro(named: "modifySave", instructions: [
  .any(.ld(.a, .imm8)),
  .any(.ld(.imm16addr, .a))
  ], code: [
    .ld(.a, .arg(2)),
    .ld(.arg(1), .a)
  ], validArgumentValues: [
    1: IndexSet(integersIn: 0xA100..<0xAB8F)
])

disassembly.defineMacro(named: "resetAudio", template: """
xor  a
ld   [$D361], a
ld   [$D371], a
ld   [$D31F], a

ld   [$D32F], a
ld   [$D33F], a

ld   [$D39E], a
ld   [$D39F], a

ld   [$D3D9], a
ld   [$D3DA], a

ld   [$D3B6], a
ld   [$D3B7], a
ld   [$D3B8], a
ld   [$D3B9], a
ld   [$D3BA], a
ld   [$D3BB], a

ld   [$D394], a
ld   [$D395], a
ld   [$D396], a

ld   [$D390], a
ld   [$D391], a
ld   [$D392], a

ld   [$D3C6], a
ld   [$D3C7], a
ld   [$D3C8], a

ld   [$D3A0], a
ld   [$D3A1], a
ld   [$D3A2], a

ld   [$D3CD], a

ld   [$D3D6], a
ld   [$D3D7], a
ld   [$D3D8], a

ld   [$D3DC], a

ld   [$D3E7], a

ld   [$D3E2], a
ld   [$D3E3], a
ld   [$D3E4], a

ld   a, %00001000
ld   [$FF12], a
ld   [$FF17], a

ld   a, %10000000
ld   [$FF14], a
ld   [$FF19], a

xor  a
ld   [$FF10], a

ld   [$ff1a], a
""")

try disassembly.writeTo(directory: "/Users/featherless/workbench/gbdis/disassembly")

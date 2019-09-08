import Foundation
import LR35902
import DisassemblyRequest
#if os(Linux)
import FoundationNetworking
#endif

let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"))

var disassemblyRequest = DisassemblyRequest<LR35902.Address, LR35902.Instruction>(data: data)

populateRequestWithHardwareDefaults(disassemblyRequest)
populateRequestWithGameData(disassemblyRequest)

let requestData = try disassemblyRequest.toWireformat()

//var request = URLRequest(url: URL(string: "http://syntropy.run/disassemble")!)
//request.httpMethod = "POST"
//request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
//
//let semaphore = DispatchSemaphore(value: 0)
//let task = URLSession.shared.uploadTask(with: request, from: requestData) { data, response, error in
//  if let error = error {
//    print("error: \(error)")
//    return
//  }
//  guard let response = response as? HTTPURLResponse else {
//    print("Missing response")
//    return
//  }
//  guard (200...299).contains(response.statusCode) else {
//    print("Request did not succeed:")
//    print(response)
//    return
//  }
//  if let mimeType = response.mimeType,
//    mimeType == "application/json",
//    let data = data,
//    let dataString = String(data: data, encoding: .utf8) {
//    print("got data: \(dataString)")
//  }
//  print(response)
//  print(String(data: data!, encoding: .utf8)!)
//  semaphore.signal()
//}
//task.resume()
//semaphore.wait()
//exit(0)

// MARK: - TODO: WIRE TRANSFER

// MARK: - Receipt of data

let _request = try Disassembly_Request(serializedData: requestData)

let disassembly = LR35902.Disassembly(rom: _request.binary)

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

var jumpTableIndex = 0

func disassembleJumpTable(within range: Range<LR35902.Address>, in bank: LR35902.Bank,
                          selectedBank: LR35902.Bank? = nil,
                          bankTable: [UInt8: LR35902.Bank]? = nil,
                          functionNames: [UInt8: String]? = nil) {
  //  assert((range.upperBound - range.lowerBound) <= 256)
  jumpTableIndex += 1
  disassembly.setJumpTable(at: range, in: bank)

  let bankSelector: (UInt8) -> LR35902.Bank?
  if let selectedBank = selectedBank {
    disassembly.register(bankChange: selectedBank, at: range.lowerBound - 1, in: bank)
    bankSelector = { _ in
      selectedBank
    }
  } else if let bankTable = bankTable {
    bankSelector = {
      bankTable[$0]
    }
  } else {
    return
  }
  let cartRange = LR35902.cartAddress(for: range.lowerBound, in: bank)!..<LR35902.cartAddress(for: range.upperBound, in: bank)!
  for location in stride(from: cartRange.lowerBound, to: cartRange.upperBound, by: 2) {
    let lowByte = data[Int(location)]
    let highByte = data[Int(location + 1)]
    let address: LR35902.Address = (LR35902.Address(highByte) << 8) | LR35902.Address(lowByte)
    if address < 0x8000 {
      let index = UInt8((location - cartRange.lowerBound) / 2)
      let effectiveBank: LR35902.Bank
      let addressAndBank = LR35902.addressAndBank(from: location)
      if address < 0x4000 {
        effectiveBank = 0
      } else {
        guard let selectedBank = bankSelector(index) else {
          continue
        }
        disassembly.register(bankChange: selectedBank, at: addressAndBank.address, in: bank)
        effectiveBank = selectedBank
      }
      if effectiveBank == 0 && address >= 0x4000 {
        continue // Don't disassemble if we're not confident what the bank is.
      }
      let name: String
      if let functionName = functionNames?[index] {
        name = "JumpTable_\(functionName)"
      } else {
        name = "JumpTable_\(address.hexString)_\(effectiveBank.hexString)"
      }
      disassembly.registerTransferOfControl(to: address, in: effectiveBank, from: addressAndBank.address, in: addressAndBank.bank, spec: .jp(nil, .imm16))
      disassembly.defineFunction(startingAt: address, in: effectiveBank, named: name)
    }
  }
}

for (name, datatype) in _request.hints.datatypes {
  let representation: LR35902.Disassembly.Datatype.Representation
  switch datatype.representation {
  case .hexadecimal:
    representation = .hexadecimal
  case .binary:
    representation = .binary
  case .decimal:
    representation = .decimal
  case .UNRECOGNIZED(_):
    continue
  }
  let valueNames = datatype.valueNames.reduce(into: [:]) { accumulator, element in
    accumulator[UInt8(element.key)] = element.value
  }
  switch datatype.kind {
  case .any:
    disassembly.createDatatype(named: name, representation: representation)
  case .bitmask:
    disassembly.createDatatype(named: name, bitmask: valueNames, representation: representation)
  case .enumeration:
    disassembly.createDatatype(named: name, enumeration: valueNames, representation: representation)
  case .UNRECOGNIZED(_):
    continue
  }
}

for (address, global) in _request.hints.globals {
  disassembly.createGlobal(at: LR35902.Address(address), named: global.name, dataType: global.datatype)
}

for (name, macro) in _request.hints.macros {
  let macroLines: [LR35902.Disassembly.MacroLine] = macro.patterns.map {
    let instructionData: Data = $0.opcode + $0.operands
    let cpu = LR35902(cartridge: instructionData)
    let spec = cpu.spec(at: 0, in: 0)!
    if let instruction = cpu.instruction(at: 0, in: 0, spec: spec) {
      return .instruction(instruction)
    } else if $0.argument > 0 {
      return .any(spec, argument: $0.argument)
    } else {
      return .any(spec)
    }
  }
  disassembly.defineMacro(named: name, instructions: macroLines)
}

disassembly.mapCharacter(0x5e, to: "'")
disassembly.mapCharacter(0xd9, to: "<flower>")
disassembly.mapCharacter(0xe1, to: "<ribbon>")
disassembly.mapCharacter(0xda, to: "<footprint>")
disassembly.mapCharacter(0xdc, to: "<skull>")
disassembly.mapCharacter(0xdd, to: "<link>")
disassembly.mapCharacter(0xde, to: "<marin>")
disassembly.mapCharacter(0xdf, to: "<tarin>")
disassembly.mapCharacter(0xe0, to: "<yoshi>")
disassembly.mapCharacter(0xe1, to: "<ribbon>")
disassembly.mapCharacter(0xe2, to: "<dogfood>")
disassembly.mapCharacter(0xe3, to: "<bananas>")
disassembly.mapCharacter(0xe4, to: "<stick>")
disassembly.mapCharacter(0xe5, to: "<honeycomb>")
disassembly.mapCharacter(0xe6, to: "<pineapple>")
disassembly.mapCharacter(0xe7, to: "<flower2>")
disassembly.mapCharacter(0xe8, to: "<broom>")
disassembly.mapCharacter(0xe9, to: "<fishhook>")
disassembly.mapCharacter(0xea, to: "<bra>")
disassembly.mapCharacter(0xeb, to: "<scale>")
disassembly.mapCharacter(0xec, to: "<glass>")
disassembly.mapCharacter(0xed, to: "<letter>")
disassembly.mapCharacter(0xee, to: "<dpad>")
disassembly.mapCharacter(0xf0, to: "<up>")
disassembly.mapCharacter(0xf1, to: "<down>")
disassembly.mapCharacter(0xf2, to: "<left>")
disassembly.mapCharacter(0xf3, to: "<right>")
disassembly.mapCharacter(0xfe, to: "<ask>")
disassembly.mapCharacter(0xff, to: "@")

let numberOfRestartAddresses: LR35902.Address = 8
let restartSize: LR35902.Address = 8
let rstAddresses = (1..<numberOfRestartAddresses).map { ($0 * restartSize)..<($0 * restartSize + restartSize) }
rstAddresses.forEach {
  disassembly.setData(at: $0, in: 0x00)
}

disassembly.setData(at: 0x0006..<0x0008, in: 0x00)

disassembly.setSoftTerminator(at: 0x05F1, in: 0x00) // This function can't logically proceed past this point.

disassembly.setData(at: 0x4000..<(0x4000 + 0x0400), in: 0x0C)
disassembly.setData(at: 0x4000..<(0x4000 + 0x0400), in: 0x0F)
disassembly.setData(at: 0x4000..<(0x4000 + 0x0600), in: 0x0D)
disassembly.setData(at: 0x4000..<(0x4000 + 0x1000), in: 0x10)
disassembly.setData(at: 0x4000..<(0x4000 + 0x1800), in: 0x13)
disassembly.setData(at: 0x4220..<(0x4220 + 0x0020), in: 0x0C)
disassembly.setData(at: 0x4400..<(0x4400 + 0x0500), in: 0x0F)
disassembly.setData(at: 0x47A0..<(0x47A0 + 0x0020), in: 0x0C)
disassembly.setData(at: 0x47C0..<(0x47C0 + 0x0040), in: 0x0C)
disassembly.setData(at: 0x4800..<(0x4800 + 0x1000), in: 0x0C)
disassembly.setData(at: 0x4900..<(0x4900 + 0x0700), in: 0x0F)
disassembly.setData(at: 0x4C00..<(0x4C00 + 0x0400), in: 0x0C)
disassembly.setData(at: 0x5000..<(0x5000 + 0x0100), in: 0x0C)
disassembly.setData(at: 0x5000..<(0x5000 + 0x0800), in: 0x0C)
disassembly.setData(at: 0x5000..<(0x5000 + 0x0800), in: 0x0F)
disassembly.setData(at: 0x5200..<(0x5200 + 0x0600), in: 0x0C)
disassembly.setData(at: 0x5400..<(0x5400 + 0x0600), in: 0x10)
disassembly.setData(at: 0x57E0..<(0x57E0 + 0x0010), in: 0x0C)
disassembly.setData(at: 0x5800..<(0x5800 + 0x1000), in: 0x13)
disassembly.setData(at: 0x5919..<(0x5919 + 0x0010), in: 0x05)
disassembly.setData(at: 0x5939..<(0x5939 + 0x0010), in: 0x05)
disassembly.setData(at: 0x6000..<(0x6000 + 0x0600), in: 0x10)
disassembly.setData(at: 0x6000..<(0x6000 + 0x0800), in: 0x0F)
disassembly.setData(at: 0x6000..<(0x6000 + 0x0800), in: 0x12)
disassembly.setData(at: 0x6600..<(0x6600 + 0x0080), in: 0x12)
disassembly.setData(at: 0x6700..<(0x6700 + 0x0400), in: 0x10)
disassembly.setData(at: 0x6800..<(0x6800 + 0x0400), in: 0x13)
disassembly.setData(at: 0x6800..<(0x6800 + 0x0800), in: 0x13)
disassembly.setData(at: 0x6800..<(0x6800 + 0x0800), in: 0x13)
disassembly.setData(at: 0x7000..<(0x7000 + 0x0800), in: 0x13)
disassembly.setData(at: 0x7000..<(0x7000 + 0x0800), in: 0x13)
disassembly.setData(at: 0x7500..<(0x7500 + 0x0040), in: 0x12)
disassembly.setData(at: 0x7500..<(0x7500 + 0x0200), in: 0x12)
disassembly.setData(at: 0x7D31..<(0x7D31 + 0x0080), in: 0x01)

// MARK: - Jump tables

disassembleJumpTable(within: 0x04b3..<0x04F5, in: 0x00, selectedBank: 0x00)
disassembleJumpTable(within: 0x1b6e..<0x1b90, in: 0x00, selectedBank: 0x00,
                     functionNames: disassembly.valuesForDatatype(named: "ANIMATED_TILES")!)

disassembleJumpTable(within: 0x0ad2..<0x0aea, in: 0x00, selectedBank: 0x00)
disassembleJumpTable(within: 0x215f..<0x217d, in: 0x00, selectedBank: 0x00)

disassembleJumpTable(within: 0x0c82..<0x0C8C, in: 0x00, selectedBank: 0x01)
disassembleJumpTable(within: 0x0d33..<0x0d49, in: 0x00, selectedBank: 0x03)  // TODO: This may be called with different banks.
disassembleJumpTable(within: 0x30fb..<0x310d, in: 0x00, selectedBank: 0x00)
disassembleJumpTable(within: 0x3114..<0x3138, in: 0x00, selectedBank: 0x00)
disassembleJumpTable(within: 0x392b..<0x393d, in: 0x00, selectedBank: 0x03)

disassembleJumpTable(within: 0x4187..<0x4191, in: 0x01, selectedBank: 0x01)
disassembleJumpTable(within: 0x4322..<0x4332, in: 0x01, selectedBank: 0x01)

disassembleJumpTable(within: 0x5378..<0x5392, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x5b2f..<0x5b3f, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x5d45..<0x5d63, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x6b4e..<0x6b56, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x6b74..<0x6b7c, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x6b9a..<0x6ba2, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x6c1f..<0x6c25, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x7c53..<0x7c5d, in: 0x02, selectedBank: 0x02)

disassembleJumpTable(within: 0x4976..<(0x4976 + 233 * 2), in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5aa6..<0x5ab8, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5bf5..<0x5bfd, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5de0..<0x5de6, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5e43..<0x5e53, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5ef7..<0x5f01, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x6353..<0x6375, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x700b..<0x7017, in: 0x03, selectedBank: 0x03)

disassembleJumpTable(within: 0x4015..<0x401f, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4091..<0x4099, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x42e5..<0x42eb, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4328..<0x4334, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x49d0..<0x49d4, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x49dd..<0x49e5, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4b52..<0x4b56, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4e0d..<0x4e13, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4e8c..<0x4e94, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x5078..<0x5080, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x50a1..<0x50a7, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x512f..<0x5135, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x553f..<0x5545, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x55b0..<0x55b6, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x56bd..<0x56C5, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x5E23..<0x5E29, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x5FCF..<0x5FD5, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x6081..<0x6089, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x6802..<0x6806, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x69B0..<0x69B6, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x6EB6..<0x6ED0, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x747B..<0x7487, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x76B4..<0x76c2, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x79E5..<0x79F7, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x7CCE..<0x7CD2, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x7DA6..<0x7DAC, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x7E82..<0x7E8A, in: 0x04, selectedBank: 0x04)

disassembleJumpTable(within: 0x40AE..<0x40B2, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x4169..<0x4173, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x461E..<0x4626, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x47F9..<0x4803, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x4988..<0x4990, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x4BFF..<0x4C09, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x4EB7..<0x4EC3, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x51A4..<0x51AA, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x52C4..<0x52CA, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x5395..<0x539B, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x54B0..<0x54B8, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x54CD..<0x54D1, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x5625..<0x562B, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x59C1..<0x59C9, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x59CC..<0x59D6, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x5AFA..<0x5B18, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x5C64..<0x5C6E, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x61BD..<0x61C1, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x6224..<0x6228, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x628B..<0x628F, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x62CD..<0x62D9, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x6C5D..<0x6C65, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x7210..<0x721A, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x6701..<0x6705, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x67E9..<0x67EF, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x6C50..<0x6C56, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x7B4E..<0x7B56, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x7D93..<0x7D99, in: 0x05, selectedBank: 0x05)

disassembleJumpTable(within: 0x404C..<0x4056, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4172..<0x417C, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x426E..<0x4278, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4585..<0x458F, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x47F8..<0x4802, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4964..<0x496A, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4AE0..<0x4AE8, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4BFC..<0x4C00, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5143..<0x514F, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x53D1..<0x53D9, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x54DB..<0x54EB, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x56EE..<0x56F6, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5824..<0x5834, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5B71..<0x5B79, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5DA6..<0x5DAE, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5F6A..<0x5F74, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6117..<0x611D, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x61DA..<0x61DE, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x62F0..<0x62F6, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6757..<0x675B, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x68D7..<0x68E1, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6C81..<0x6C85, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6D17..<0x6D1F, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6F7A..<0x6F80, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7069..<0x706F, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x726A..<0x7270, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7383..<0x7389, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x74C5..<0x74C9, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7574..<0x757A, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7621..<0x7629, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x773F..<0x7747, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7AC8..<0x7ACC, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7C7F..<0x7C8B, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7DBF..<0x7DC9, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7EC7..<0x7ECB, in: 0x06, selectedBank: 0x06)

// TODO:

disassembleJumpTable(within: 0x40B5..<0x40B7, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x42CD..<0x42CF, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4545..<0x4547, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4715..<0x4717, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x489D..<0x489F, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x49FE..<0x4A00, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4AB3..<0x4AB5, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4B8E..<0x4B90, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4CDF..<0x4CE1, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4F1A..<0x4F1C, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5124..<0x5126, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5627..<0x5629, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x59B4..<0x59B6, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5B95..<0x5B97, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5E3C..<0x5E3E, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x6221..<0x6223, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x640F..<0x6411, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x64BC..<0x64BE, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x654C..<0x654E, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x66A4..<0x66A6, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x6862..<0x6864, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x69CF..<0x69D1, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x71EB..<0x71ED, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x731A..<0x731C, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x747F..<0x7481, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x7547..<0x7549, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x772F..<0x7731, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x788F..<0x7891, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x7D88..<0x7D8A, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5001..<0x5003, in: 0x14, selectedBank: 0x14)
disassembleJumpTable(within: 0x40A7..<0x40A9, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x410C..<0x410E, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x41D6..<0x41D8, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x4249..<0x424B, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x42BC..<0x42BE, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x44E8..<0x44EA, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x45F1..<0x45F3, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x4728..<0x472A, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x4F6B..<0x4F6D, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x50BB..<0x50BD, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x7701..<0x7703, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x78E1..<0x78E3, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x7C41..<0x7C43, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x488B..<0x488D, in: 0x17, selectedBank: 0x17)
disassembleJumpTable(within: 0x754D..<0x754F, in: 0x17, selectedBank: 0x17)
disassembleJumpTable(within: 0x401F..<0x4021, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4390..<0x4392, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4547..<0x4549, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4962..<0x4964, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4A04..<0x4A06, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4BA1..<0x4BA3, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4BFC..<0x4BFE, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4CF7..<0x4CF9, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4DE8..<0x4DEA, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4E56..<0x4E58, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x52CC..<0x52CE, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x552B..<0x552D, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x58AB..<0x58AD, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x5B93..<0x5B95, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x5E21..<0x5E23, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x5F02..<0x5F04, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x60E9..<0x60EB, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x61A3..<0x61A5, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x63F2..<0x63F4, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x65B3..<0x65B5, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x6A65..<0x6A67, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x6F70..<0x6F72, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x6FFD..<0x6FFF, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x7175..<0x7177, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x735D..<0x735F, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x773D..<0x773F, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x7828..<0x782A, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x7E82..<0x7E84, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x406A..<0x406C, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x428F..<0x4291, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4495..<0x4497, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x461C..<0x461E, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4942..<0x4944, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4A33..<0x4A35, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4CB3..<0x4CB5, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4D7B..<0x4D7D, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x51A9..<0x51AB, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5350..<0x5352, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x54DD..<0x54DF, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5609..<0x560B, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5719..<0x571B, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5823..<0x5825, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5B29..<0x5B2B, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5CB6..<0x5CB8, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5E07..<0x5E09, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5F1E..<0x5F20, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x614A..<0x614C, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x65E2..<0x65E4, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x682E..<0x6830, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x68B7..<0x68B9, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x69CC..<0x69CE, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x6BF5..<0x6BF7, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x6E51..<0x6E53, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x70CD..<0x70CF, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x76A8..<0x76AA, in: 0x19, selectedBank: 0x19)

// MARK: - Entity table.

var entityJumpTableBanks: [UInt8: LR35902.Bank] = [:]
for (value, name) in disassembly.valuesForDatatype(named: "ENTITY")! {
  let address = 0x4000 + LR35902.Address(value)
  disassembly.setLabel(at: address, in: 0x03, named: "\(name)_bank")
  disassembly.setData(at: address, in: 0x03)

  let entityBankLocation = LR35902.cartAddress(for: address, in: 0x03)!
  let bank = data[Int(entityBankLocation)]
  entityJumpTableBanks[value] = bank
}

disassembly.register(bankChange: 0x08, at: 0x0A09, in: 0x00)
disassembly.register(bankChange: 0x08, at: 0x0A85, in: 0x00)
disassembly.register(bankChange: 0x03, at: 0x3945, in: 0x00)
disassembly.register(bankChange: 0x00, at: 0x3951, in: 0x00)
disassembleJumpTable(within: 0x3953..<(0x3953 + 0xFF * 2), in: 0x00,
                     bankTable: entityJumpTableBanks,
                     functionNames: disassembly.valuesForDatatype(named: "ENTITY")!)

disassembly.disassembleAsGameboyCartridge()

// MARK: - Bank 0 (00)

disassembly.defineFunction(startingAt: 0x0150, in: 0x00, named: "Main")
disassembly.setPreComment(at: 0x0156, in: 0x00, text: "Reset the palette registers to zero.")
disassembly.setPreComment(at: 0x015D, in: 0x00, text: "Clears 6144 bytes of video ram. Graphics vram location for OBJ and BG tiles start at $8000 and end at $97FF; for a total of 0x1800 bytes.")
disassembly.setLabel(at: 0x01a6, in: 0x00, named: "frameDidRender")
disassembly.setPreComment(at: 0x01b7, in: 0x00, text: "Load a with a value that is non-zero every other frame.")
disassembly.setLabel(at: 0x01aa, in: 0x00, named: "renderLoop_setScrollY")
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
disassembly.setLabel(at: 0x038a, in: 0x00, named: "engineIsPaused")
disassembly.setLabel(at: 0x03a4, in: 0x00, named: "checkEnginePaused")
disassembly.defineFunction(startingAt: 0x04a1, in: 0x00, named: "LoadMapData")
disassembly.setLabel(at: 0x04f5, in: 0x00, named: "loadMapZero")
disassembly.setLabel(at: 0x0516, in: 0x00, named: "cleanupAndReturn")
disassembly.defineFunction(startingAt: 0x07B9, in: 0x00, named: "SetBank")
disassembly.defineFunction(startingAt: 0x0844, in: 0x00, named: "PlayAudioStep")
disassembly.defineFunction(startingAt: 0x27fe, in: 0x00, named: "ReadJoypadState")
disassembly.setType(at: 0x2827, in: 0x00, to: "binary")
disassembly.setPreComment(at: 0x282A, in: 0x00, text: "Store the read joypad state into c")
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

disassembly.defineMacro(named: "callcb", instructions: [
  .any(.ld(.a, .imm8), argumentText: "bank(\\1)"),
  .instruction(.init(spec: .ld(.imm16addr, .a), imm16: 0x2100)),
  .any(.call(nil, .imm16), argument: 1)
], validArgumentValues: [
  1: IndexSet(integersIn: 0x4000..<0x8000)
])

disassembly.defineMacro(named: "modifySave", instructions: [
  .any(.ld(.a, .imm8), argument: 2),
  .any(.ld(.imm16addr, .a), argument: 1)
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

let files = try disassembly.generateFiles()

let directory = "/Users/featherless/workbench/gbdis/disassembly"
let fm = FileManager.default
let directoryUrl = URL(fileURLWithPath: directory)
try fm.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)

extension FileManager {
  fileprivate func restartFile(atPath path: String) throws -> FileHandle {
    if fileExists(atPath: path) {
      try removeItem(atPath: path)
    }
    createFile(atPath: path, contents: Data(), attributes: nil)
    return try FileHandle(forWritingTo: URL(fileURLWithPath: path))
  }
}

for (file, data) in files {
  let handle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent(file).path)
  handle.write(data)
}

import Foundation
import LR35902

let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"))

let cpu = LR35902(rom: data)

cpu.initializeDisassembly()

cpu.disassembly.setLabel(at: 0x0003, in: 0x00, named: "DEBUG_TOOL")
cpu.disassembly.setData(at: 0x0003, in: 0x00)

cpu.disassembly.setLabel(at: 0x0150, in: 0x00, named: "Main")
cpu.disassembly.setLabel(at: 0x2881, in: 0x00, named: "LCDOff")
cpu.disassembly.setLabel(at: 0x460F, in: 0x01, named: "InitSaves")
cpu.disassembly.setPreComment(at: 0x0156, in: 0x00, text: "Reset the palette registers to zero.")

cpu.disassembly.setPreComment(at: 0x015D, in: 0x00, text: "Clears 6144 bytes of video ram. Graphics vram location for OBJ and BG tiles start at $8000 and end at $97FF; for a total of 0x1800 bytes.")
cpu.disassembly.setLabel(at: 0x2999, in: 0x00, named: "ClearMemoryRegion")

cpu.disassembly.defineMacro(named: "callcb", instructions: [
  .any(.ld(.a, .immediate8)),
  .instruction(.init(spec: .ld(.immediate16address, .a), immediate16: 0x2100)),
  .any(.call(.immediate16))
], code: [
  .ld(.a, .macro("bank(\\1)")),
  .ld(.immediate16address, .a),
  .call(.arg(1))
], validArgumentValues: [
  1: IndexSet(integersIn: 0x4000..<0x8000)
])

cpu.disassembly.createGlobal(at: 0xA100, named: "SAVEFILES")

try cpu.disassembly.writeTo(directory: "/Users/featherless/workbench/gbdis/disassembly", cpu: cpu)

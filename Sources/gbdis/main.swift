import Foundation
import LR35902

let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"))

let cpu = LR35902(rom: data)

cpu.initializeDisassembly()

cpu.disassembly.setLabel(at: 0x0003, in: 0x00, named: "DEBUG_TOOL")
cpu.disassembly.setData(at: 0x0003, in: 0x00)

cpu.disassembly.setLabel(at: 0x0150, in: 0x00, named: "Main")
cpu.disassembly.setLabel(at: 0x2881, in: 0x00, named: "LCDOff")
cpu.disassembly.setPreComment(at: 0x0156, in: 0x00, text: "Reset the palette registers to zero.")

try cpu.disassembly.writeTo(directory: "/Users/featherless/workbench/gbdis/disassembly", cpu: cpu)

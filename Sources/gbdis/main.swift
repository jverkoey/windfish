import Foundation
import LR35902

let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"))

let cpu = LR35902(rom: data)

cpu.initializeDisassembly()

cpu.disassembly.setLabel(at: 0x0003, in: 0x00, named: "DEBUG_TOOL")

try cpu.disassembly.writeTo(directory: "/Users/featherless/workbench/gbdis/disassembly", cpu: cpu)

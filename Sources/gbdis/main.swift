import Foundation
import LR35902

let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"))

let cpu = LR35902(rom: data)

cpu.initializeDisassembly()

try cpu.disassembly.writeTo(directory: "/Users/featherless/workbench/gbdis/disassembly", cpu: cpu)

import Foundation
import LR35902

let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"))

let cpu = LR35902(rom: data)

let numberOfRestartAddresses = 8
let restartSize = 8
let rstAddresses = (0..<numberOfRestartAddresses)
  .map { UInt16($0 * restartSize)..<UInt16($0 * restartSize + restartSize) }

cpu.disassembly.setLabel(at: 0x0100, in: 0x00, named: "Boot")

rstAddresses.forEach {
  cpu.disassemble(range: $0, inBank: 0)
}
cpu.disassemble(range: 0x0100..<0x4000, inBank: 0)

try cpu.disassembly.writeTo(directory: "/Users/featherless/workbench/gbdis/disassembly", cpu: cpu)

import Foundation
import Windfish
import DisassemblyRequest

func populateRequestWithHardwareDefaults(_ request: DisassemblyRequest<LR35902.Address, Gameboy.Cartridge.Location, LR35902.Instruction>) {
  populateRequestWithHardwareDatatypes(request)
  populateRequestWithHardwareGlobals(request)
  populateRequestWithHardwareMacros(request)
  populateRequestWithHardwareLabels(request)
}

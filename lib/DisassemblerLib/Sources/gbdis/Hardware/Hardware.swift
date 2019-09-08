import Foundation
import LR35902
import DisassemblyRequest

func populateRequestWithHardwareDefaults(_ request: DisassemblyRequest<LR35902.Address, LR35902.CartridgeLocation, LR35902.Instruction>) {
  populateRequestWithHardwareDatatypes(request)
  populateRequestWithHardwareGlobals(request)
  populateRequestWithHardwareMacros(request)
}

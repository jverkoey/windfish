import Foundation
import LR35902
import DisassemblyRequest

func populateRequestWithHardwareDefaults(_ request: DisassemblyRequest<LR35902.Address>) {
  populateRequestWithHardwareDatatypes(request)
  populateRequestWithHardwareGlobals(request)
}

import Foundation
import LR35902
import DisassemblyRequest

func populateRequestWithGameData(_ request: DisassemblyRequest<LR35902.Address>) {
  populateRequestWithGameDatatypes(request)
  populateRequestWithGameGlobals(request)
}

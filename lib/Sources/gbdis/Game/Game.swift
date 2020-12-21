import Foundation
import Windfish
import DisassemblyRequest

func populateRequestWithGameData(_ request: DisassemblyRequest<LR35902.Address, Gameboy.Cartridge.Location, LR35902.Instruction>) {
  populateRequestWithGameDatatypes(request)
  populateRequestWithGameGlobals(request)
  populateRequestWithGameMacros(request)
  populateRequestWithGameLabels(request)
}

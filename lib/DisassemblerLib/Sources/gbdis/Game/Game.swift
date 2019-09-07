import Foundation
import LR35902
import DisassemblyRequest

func populateRequestWithGameData(_ request: DisassemblyRequest<LR35902.Address, LR35902.Instruction>) {
  populateRequestWithGameDatatypes(request)
  populateRequestWithGameGlobals(request)

//  request.createMacro(named: "copyMemory", pattern: [
//    .any(.ld(.a, .imm16addr), argument: 1),
//    .any(.ld(.imm16addr, .a), argument: 2),
//  ])
}

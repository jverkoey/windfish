import Foundation
import LR35902
import DisassemblyRequest

func populateRequestWithGameLabels(_ request: DisassemblyRequest<LR35902.Address, LR35902.CartridgeLocation, LR35902.Instruction>) {
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x01a6, in: 0x00)!, to: "frameDidRender")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x01aa, in: 0x00)!, to: "renderLoop_setScrollY")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x01be, in: 0x00)!, to: "defaultShakeBehavior")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x01c4, in: 0x00)!, to: "setScrollY")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x01f5, in: 0x00)!, to: "playAudio")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x01fb, in: 0x00)!, to: "skipAudio")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x03bd, in: 0x00)!, to: "waitForNextFrame")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x038a, in: 0x00)!, to: "engineIsPaused")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x03a4, in: 0x00)!, to: "checkEnginePaused")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x04f5, in: 0x00)!, to: "loadMapZero")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x0516, in: 0x00)!, to: "cleanupAndReturn")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x415d, in: 0x1b)!, to: "AudioData")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x4099, in: 0x17)!, to: "CreditsText")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x401e, in: 0x1f)!, to: "PlayAudioStep_Start")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x53e6, in: 0x1f)!, to: "ClearActiveSquareSound")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x6385, in: 0x1f)!, to: "ClearActiveWaveSound")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x650e, in: 0x1f)!, to: "_InitNoiseSoundNoNoiseSound")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x7a28, in: 0x1f)!, to: "ClearActiveNoiseSound")
  request.setLabel(at: LR35902.cartridgeLocation(for: 0x7a60, in: 0x1f)!, to: "_ShiftHL")
}

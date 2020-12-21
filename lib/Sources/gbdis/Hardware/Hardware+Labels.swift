import Foundation
import LR35902
import DisassemblyRequest

func populateRequestWithHardwareLabels(_ request: DisassemblyRequest<LR35902.Address, Gameboy.Cartridge.Location, LR35902.Instruction>) {
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0040, in: 0x00)!, to: "VBlankInterrupt")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0048, in: 0x00)!, to: "LCDCInterrupt")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0050, in: 0x00)!, to: "TimerOverflowInterrupt")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0058, in: 0x00)!, to: "SerialTransferCompleteInterrupt")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0060, in: 0x00)!, to: "JoypadTransitionInterrupt")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0100, in: 0x00)!, to: "Boot")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0104, in: 0x00)!, to: "HeaderLogo")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0134, in: 0x00)!, to: "HeaderTitle")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0144, in: 0x00)!, to: "HeaderNewLicenseeCode")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x0147, in: 0x00)!, to: "HeaderCartridgeType")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x014B, in: 0x00)!, to: "HeaderOldLicenseeCode")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x014C, in: 0x00)!, to: "HeaderMaskROMVersion")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x014D, in: 0x00)!, to: "HeaderComplementCheck")
  request.setLabel(at: Gameboy.Cartridge.cartridgeLocation(for: 0x014E, in: 0x00)!, to: "HeaderGlobalChecksum")
}

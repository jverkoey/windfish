import Foundation
import Windfish
import DisassemblyRequest

func populateRequestWithHardwareDatatypes(_ request: DisassemblyRequest<LR35902.Address, Gameboy.Cartridge.Location, LR35902.Instruction>) {
  request.createDatatype(named: "bool", representation: .decimal, enumeration: [0: "false", 1: "true"])
  request.createDatatype(named: "decimal", representation: .decimal)
  request.createDatatype(named: "binary", representation: .binary)

  request.createDatatype(named: "HW_COLORGAMEBOY", enumeration: [
    0x00: "not_color_gameboy",
    0x80: "is_color_gameboy",
  ])
  request.createDatatype(named: "HW_SUPERGAMEBOY", enumeration: [
    0x00: "not_super_gameboy",
    0x80: "is_super_gameboy",
  ])
  request.createDatatype(named: "HW_ROMSIZE", enumeration: [
    0: "romsize_2banks",
    1: "romsize_4banks",
    2: "romsize_8banks",
    3: "romsize_16banks",
    4: "romsize_32banks",
    5: "romsize_64banks",
    6: "romsize_128banks",
    0x52: "romsize_72banks",
    0x53: "romsize_80banks",
    0x54: "romsize_96banks",
  ])
  request.createDatatype(named: "HW_RAMSIZE", enumeration: [
    0: "ramsize_none",
    1: "ramsize_1bank",
    2: "ramsize_1bank_",
    3: "ramsize_4banks",
    4: "ramsize_16banks",
  ])
  request.createDatatype(named: "HW_DESTINATIONCODE", enumeration: [
    0: "destination_japanese",
    1: "destination_nonjapanese",
  ])
  request.createDatatype(named: "HW_IE", bitmask: [
    0b0000_0001: "IE_VBLANK",
    0b0000_0010: "IE_LCDC",
    0b0000_0100: "IE_TIMEROVERFLOW",
    0b0000_1000: "IE_SERIALIO",
    0b0001_0000: "IE_PIN1013TRANSITION",
  ])
  request.createDatatype(named: "LCDCF", bitmask: [
    0b0000_0000: "LCDCF_OFF",
    0b1000_0000: "LCDCF_ON",
    0b0100_0000: "LCDCF_TILEMAP_9C00",
    0b0010_0000: "LCDCF_WINDOW_ON",
    0b0001_0000: "LCDCF_BG_CHAR_8000",
    0b0000_1000: "LCDCF_BG_TILE_9C00",
    0b0000_0100: "LCDCF_OBJ_16_16",
    0b0000_0010: "LCDCF_OBJ_DISPLAY",
    0b0000_0001: "LCDCF_BG_DISPLAY",
  ])
  request.createDatatype(named: "STATF", bitmask: [
    0b0100_0000: "STATF_LYC",
    0b0010_0000: "STATF_MODE10",
    0b0001_0000: "STATF_MODE01",
    0b0000_1000: "STATF_MODE00",
    0b0000_0100: "STATF_LYCF",
    0b0000_0010: "STATF_OAM",
    0b0000_0001: "STATF_VB",
    0b0000_0000: "STATF_HB"
  ])
  request.createDatatype(named: "BUTTON", bitmask: [
    0b0000_0001: "J_RIGHT",
    0b0000_0010: "J_LEFT",
    0b0000_0100: "J_UP",
    0b0000_1000: "J_DOWN",
    0b0001_0000: "J_A",
    0b0010_0000: "J_B",
    0b0100_0000: "J_SELECT",
    0b1000_0000: "J_START",
  ])
  request.createDatatype(named: "JOYPAD", bitmask: [
    0b0001_0000: "JOYPAD_DIRECTIONS",
    0b0010_0000: "JOYPAD_BUTTONS",
  ])
}


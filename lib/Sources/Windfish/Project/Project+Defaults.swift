import Foundation

import LR35902

extension Project {
  public convenience init(rom: Data?) {
    var regions: [Region] = []
    var dataTypes: [DataType] = []
    var globals: [Global] = []

    let numberOfRestartAddresses: LR35902.Address = 8
    let restartSize: LR35902.Address = 8
    let rstAddresses = (0..<numberOfRestartAddresses).map { ($0 * restartSize)..<($0 * restartSize + restartSize) }
    rstAddresses.forEach {
      regions.append(Region(regionType: Windfish.Project.Region.Kind.region, name: "RST_\($0.lowerBound.hexString)", bank: 0, address: $0.lowerBound, length: LR35902.Address($0.count)))
    }

    regions.append(contentsOf: [
      Region(regionType: Windfish.Project.Region.Kind.region, name: "VBlankInterrupt", bank: 0, address: 0x0040, length: 8),
      Region(regionType: Windfish.Project.Region.Kind.region, name: "LCDCInterrupt", bank: 0, address: 0x0048, length: 8),
      Region(regionType: Windfish.Project.Region.Kind.region, name: "TimerOverflowInterrupt", bank: 0, address: 0x0050, length: 8),
      Region(regionType: Windfish.Project.Region.Kind.region, name: "SerialTransferCompleteInterrupt", bank: 0, address: 0x0058, length: 8),
      Region(regionType: Windfish.Project.Region.Kind.region, name: "JoypadTransitionInterrupt", bank: 0, address: 0x0060, length: 8),
      Region(regionType: Windfish.Project.Region.Kind.region, name: "Boot", bank: 0, address: 0x0100, length: 4),
      Region(regionType: Windfish.Project.Region.Kind.image1bpp, name: "HeaderLogo", bank: 0, address: 0x0104, length: 0x0134 - 0x0104),
      Region(regionType: Windfish.Project.Region.Kind.string, name: "HeaderTitle", bank: 0, address: 0x0134, length: 0x0143 - 0x0134),
      Region(regionType: Windfish.Project.Region.Kind.label, name: "HeaderNewLicenseeCode", bank: 0, address: 0x0144, length: 0),
      Region(regionType: Windfish.Project.Region.Kind.label, name: "HeaderOldLicenseeCode", bank: 0, address: 0x014B, length: 0),
      Region(regionType: Windfish.Project.Region.Kind.label, name: "HeaderMaskROMVersion", bank: 0, address: 0x014C, length: 0),
      Region(regionType: Windfish.Project.Region.Kind.label, name: "HeaderComplementCheck", bank: 0, address: 0x014D, length: 0),
      Region(regionType: Windfish.Project.Region.Kind.label, name: "HeaderGlobalChecksum", bank: 0, address: 0x014E, length: 0),
    ])

    dataTypes.append(DataType(name: "hex",
                              representation: Windfish.Project.DataType.Representation.hexadecimal,
                              interpretation: Windfish.Project.DataType.Interpretation.any,
                              mappings: []))
    dataTypes.append(DataType(name: "decimal",
                              representation: Windfish.Project.DataType.Representation.decimal,
                              interpretation: Windfish.Project.DataType.Interpretation.any,
                              mappings: []))
    dataTypes.append(DataType(name: "binary",
                              representation: Windfish.Project.DataType.Representation.binary,
                              interpretation: Windfish.Project.DataType.Interpretation.any,
                              mappings: []))
    dataTypes.append(DataType(name: "bool",
                              representation: Windfish.Project.DataType.Representation.decimal,
                              interpretation: Windfish.Project.DataType.Interpretation.enumerated,
                              mappings: [
                                DataType.Mapping(name: "false", value: 0),
                                DataType.Mapping(name: "true", value: 1)
                              ]))

    dataTypes.append(DataType(name: "HW_COLORGAMEBOY",
                              representation: Windfish.Project.DataType.Representation.hexadecimal,
                              interpretation: Windfish.Project.DataType.Interpretation.enumerated,
                              mappings: [
                                DataType.Mapping(name: "not_color_gameboy", value: 0x00),
                                DataType.Mapping(name: "is_color_gameboy", value: 0x80),
                              ]))
    dataTypes.append(DataType(name: "HW_SUPERGAMEBOY",
                              representation: Windfish.Project.DataType.Representation.hexadecimal,
                              interpretation: Windfish.Project.DataType.Interpretation.enumerated,
                              mappings: [
                                DataType.Mapping(name: "not_super_gameboy", value: 0x00),
                                DataType.Mapping(name: "is_super_gameboy", value: 0x80),
                              ]))
    dataTypes.append(DataType(name: "HW_ROMSIZE",
                              representation: Windfish.Project.DataType.Representation.hexadecimal,
                              interpretation: Windfish.Project.DataType.Interpretation.enumerated,
                              mappings: [
                                DataType.Mapping(name: "romsize_2banks", value: 0),
                                DataType.Mapping(name: "romsize_4banks", value: 1),
                                DataType.Mapping(name: "romsize_8banks", value: 2),
                                DataType.Mapping(name: "romsize_16banks", value: 3),
                                DataType.Mapping(name: "romsize_32banks", value: 4),
                                DataType.Mapping(name: "romsize_64banks", value: 5),
                                DataType.Mapping(name: "romsize_128banks", value: 6),
                                DataType.Mapping(name: "romsize_72banks", value: 0x52),
                                DataType.Mapping(name: "romsize_80banks", value: 0x53),
                                DataType.Mapping(name: "romsize_96banks", value: 0x54),
                              ]))
    dataTypes.append(DataType(name: "HW_CARTRIDGETYPE",
                              representation: Windfish.Project.DataType.Representation.hexadecimal,
                              interpretation: Windfish.Project.DataType.Interpretation.enumerated,
                              mappings: [
                                DataType.Mapping(name: "cartridge_romonly", value: 0),
                                DataType.Mapping(name: "cartridge_mbc1", value: 1),
                                DataType.Mapping(name: "cartridge_mbc1_ram", value: 2),
                                DataType.Mapping(name: "cartridge_mbc1_ram_battery", value: 3),
                                DataType.Mapping(name: "cartridge_mbc2", value: 5),
                                DataType.Mapping(name: "cartridge_mbc2_battery", value: 6),
                                DataType.Mapping(name: "cartridge_rom_ram", value: 8),
                                DataType.Mapping(name: "cartridge_rom_ram_battery", value: 9),
                              ]))
    dataTypes.append(DataType(name: "HW_RAMSIZE",
                              representation: Windfish.Project.DataType.Representation.hexadecimal,
                              interpretation: Windfish.Project.DataType.Interpretation.enumerated,
                              mappings: [
                                DataType.Mapping(name: "ramsize_none", value: 0),
                                DataType.Mapping(name: "ramsize_1bank", value: 1),
                                DataType.Mapping(name: "ramsize_1bank_", value: 2),
                                DataType.Mapping(name: "ramsize_4banks", value: 3),
                                DataType.Mapping(name: "ramsize_16banks", value: 4),
                              ]))
    dataTypes.append(DataType(name: "HW_DESTINATIONCODE",
                              representation: Windfish.Project.DataType.Representation.hexadecimal,
                              interpretation: Windfish.Project.DataType.Interpretation.enumerated,
                              mappings: [
                                DataType.Mapping(name: "destination_japanese", value: 0),
                                DataType.Mapping(name: "destination_nonjapanese", value: 1),
                              ]))
    dataTypes.append(DataType(name: "HW_IE",
                              representation: Windfish.Project.DataType.Representation.binary,
                              interpretation: Windfish.Project.DataType.Interpretation.bitmask,
                              mappings: [
                                DataType.Mapping(name: "IE_VBLANK", value: 0b0000_0001),
                                DataType.Mapping(name: "IE_LCDC", value: 0b0000_0010),
                                DataType.Mapping(name: "IE_TIMEROVERFLOW", value: 0b0000_0100),
                                DataType.Mapping(name: "IE_SERIALIO", value: 0b0000_1000),
                                DataType.Mapping(name: "IE_PIN1013TRANSITION", value: 0b0001_0000),
                              ]))
    dataTypes.append(DataType(name: "HW_AUDIO_ENABLE",
                              representation: Windfish.Project.DataType.Representation.binary,
                              interpretation: Windfish.Project.DataType.Interpretation.bitmask,
                              mappings: [
                                DataType.Mapping(name: "HW_AUDIO_ENABLE", value: 0b1000_0000),
                              ]))
    dataTypes.append(DataType(name: "LCDCF",
                              representation: Windfish.Project.DataType.Representation.binary,
                              interpretation: Windfish.Project.DataType.Interpretation.bitmask,
                              mappings: [
                                DataType.Mapping(name: "LCDCF_OFF", value: 0b0000_0000),
                                DataType.Mapping(name: "LCDCF_ON", value: 0b1000_0000),
                                DataType.Mapping(name: "LCDCF_TILEMAP_9C00", value: 0b0100_0000),
                                DataType.Mapping(name: "LCDCF_WINDOW_ON", value: 0b0010_0000),
                                DataType.Mapping(name: "LCDCF_BG_CHAR_8000", value: 0b0001_0000),
                                DataType.Mapping(name: "LCDCF_BG_TILE_9C00", value: 0b0000_1000),
                                DataType.Mapping(name: "LCDCF_OBJ_16_16", value: 0b0000_0100),
                                DataType.Mapping(name: "LCDCF_OBJ_DISPLAY", value: 0b0000_0010),
                                DataType.Mapping(name: "LCDCF_BG_DISPLAY", value: 0b0000_0001),
                              ]))
    dataTypes.append(DataType(name: "STATF",
                              representation: Windfish.Project.DataType.Representation.binary,
                              interpretation: Windfish.Project.DataType.Interpretation.bitmask,
                              mappings: [
                                DataType.Mapping(name: "STATF_LYC", value: 0b0100_0000),
                                DataType.Mapping(name: "STATF_MODE10", value: 0b0010_0000),
                                DataType.Mapping(name: "STATF_MODE01", value: 0b0001_0000),
                                DataType.Mapping(name: "STATF_MODE00", value: 0b0000_1000),
                                DataType.Mapping(name: "STATF_LYCF", value: 0b0000_0100),
                                DataType.Mapping(name: "STATF_OAM", value: 0b0000_0010),
                                DataType.Mapping(name: "STATF_VB", value: 0b0000_0001),
                                DataType.Mapping(name: "STATF_HB", value: 0b0000_0000),
                              ]))
    dataTypes.append(DataType(name: "BUTTON",
                              representation: Windfish.Project.DataType.Representation.binary,
                              interpretation: Windfish.Project.DataType.Interpretation.bitmask,
                              mappings: [
                                DataType.Mapping(name: "J_RIGHT", value: 0b0000_0001),
                                DataType.Mapping(name: "J_LEFT", value: 0b0000_0010),
                                DataType.Mapping(name: "J_UP", value: 0b0000_0100),
                                DataType.Mapping(name: "J_DOWN", value: 0b0000_1000),
                                DataType.Mapping(name: "J_A", value: 0b0001_0000),
                                DataType.Mapping(name: "J_B", value: 0b0010_0000),
                                DataType.Mapping(name: "J_SELECT", value: 0b0100_0000),
                                DataType.Mapping(name: "J_START", value: 0b1000_0000),
                              ]))
    dataTypes.append(DataType(name: "JOYPAD",
                              representation: Windfish.Project.DataType.Representation.binary,
                              interpretation: Windfish.Project.DataType.Interpretation.bitmask,
                              mappings: [
                                DataType.Mapping(name: "JOYPAD_DIRECTIONS", value: 0b0001_0000),
                                DataType.Mapping(name: "JOYPAD_BUTTONS", value: 0b0010_0000),
                              ]))

    globals.append(contentsOf: [
      Global(name: "HeaderIsColorGB", address: 0x0143, dataType: "HW_COLORGAMEBOY"),
      Global(name: "HeaderSGBFlag", address: 0x0146, dataType: "HW_SUPERGAMEBOY"),
      Global(name: "HeaderCartridgeType", address: 0x0147, dataType: "HW_CARTRIDGETYPE"),
      Global(name: "HeaderROMSize", address: 0x0148, dataType: "HW_ROMSIZE"),
      Global(name: "HeaderRAMSize", address: 0x0149, dataType: "HW_RAMSIZE"),
      Global(name: "HeaderDestinationCode", address: 0x014A, dataType: "HW_DESTINATIONCODE"),
      Global(name: "gbVRAM", address: 0x8000, dataType: "hex"),
      Global(name: "gbBGCHARDAT", address: 0x8800, dataType: "hex"),
      Global(name: "gbBGDAT0", address: 0x9800, dataType: "hex"),
      Global(name: "gbBGDAT1", address: 0x9c00, dataType: "hex"),
      Global(name: "gbCARTRAM", address: 0xa000, dataType: "hex"),
      Global(name: "gbRAM", address: 0xc000, dataType: "hex"),
      Global(name: "gbOAMRAM", address: 0xfe00, dataType: "hex"),
      Global(name: "gbP1", address: 0xff00, dataType: "JOYPAD"),
      Global(name: "gbSB", address: 0xff01, dataType: "hex"),
      Global(name: "gbSC", address: 0xff02, dataType: "hex"),
      Global(name: "gbDIV", address: 0xff04, dataType: "hex"),
      Global(name: "gbTIMA", address: 0xff05, dataType: "hex"),
      Global(name: "gbTMA", address: 0xff06, dataType: "hex"),
      Global(name: "gbTAC", address: 0xff07, dataType: "hex"),
      Global(name: "gbIF", address: 0xff0f, dataType: "hex"),
      Global(name: "gbAUD1SWEEP", address: 0xff10, dataType: "hex"),
      Global(name: "gbAUD1LEN", address: 0xff11, dataType: "hex"),
      Global(name: "gbAUD1ENV", address: 0xff12, dataType: "hex"),
      Global(name: "gbAUD1LOW", address: 0xff13, dataType: "hex"),
      Global(name: "gbAUD1HIGH", address: 0xff14, dataType: "hex"),
      Global(name: "gbAUD2LEN", address: 0xff16, dataType: "hex"),
      Global(name: "gbAUD2ENV", address: 0xff17, dataType: "hex"),
      Global(name: "gbAUD2LOW", address: 0xff18, dataType: "hex"),
      Global(name: "gbAUD2HIGH", address: 0xff19, dataType: "hex"),
      Global(name: "gbAUD3ENA", address: 0xff1a, dataType: "hex"),
      Global(name: "gbAUD3LEN", address: 0xff1b, dataType: "hex"),
      Global(name: "gbAUD3LEVEL", address: 0xff1c, dataType: "hex"),
      Global(name: "gbAUD3LOW", address: 0xff1d, dataType: "hex"),
      Global(name: "gbAUD3HIGH", address: 0xff1e, dataType: "hex"),
      Global(name: "gbAUD4LEN", address: 0xff20, dataType: "hex"),
      Global(name: "gbAUD4ENV", address: 0xff21, dataType: "hex"),
      Global(name: "gbAUD4POLY", address: 0xff22, dataType: "hex"),
      Global(name: "gbAUD4CONSEC", address: 0xff23, dataType: "hex"),
      Global(name: "gbAUDVOL", address: 0xff24, dataType: "binary"),
      Global(name: "gbAUDTERM", address: 0xff25, dataType: "binary"),
      Global(name: "gbAUDENA", address: 0xff26, dataType: "HW_AUDIO_ENABLE"),
      Global(name: "gbAUD3WAVERAM", address: 0xff30, dataType: "hex"),
      Global(name: "gbLCDC", address: 0xff40, dataType: "LCDCF"),
      Global(name: "gbSTAT", address: 0xff41, dataType: "STATF"),
      Global(name: "gbSCY", address: 0xff42, dataType: "decimal"),
      Global(name: "gbSCX", address: 0xff43, dataType: "decimal"),
      Global(name: "gbLY", address: 0xff44, dataType: "decimal"),
      Global(name: "gbLYC", address: 0xff45, dataType: "decimal"),
      Global(name: "gbDMA", address: 0xff46, dataType: "hex"),
      Global(name: "gbBGP", address: 0xff47, dataType: "hex"),
      Global(name: "gbOBP0", address: 0xff48, dataType: "hex"),
      Global(name: "gbOBP1", address: 0xff49, dataType: "hex"),
      Global(name: "gbWY", address: 0xff4a, dataType: "hex"),
      Global(name: "gbWX", address: 0xff4b, dataType: "hex"),
      Global(name: "gbKEY1", address: 0xff4d, dataType: "hex"),
      Global(name: "gbVBK", address: 0xff4f, dataType: "hex"),
      Global(name: "gbHDMA1", address: 0xff51, dataType: "hex"),
      Global(name: "gbHDMA2", address: 0xff52, dataType: "hex"),
      Global(name: "gbHDMA3", address: 0xff53, dataType: "hex"),
      Global(name: "gbHDMA4", address: 0xff54, dataType: "hex"),
      Global(name: "gbHDMA5", address: 0xff55, dataType: "hex"),
      Global(name: "gbRP", address: 0xff56, dataType: "hex"),
      Global(name: "gbBCPS", address: 0xff68, dataType: "hex"),
      Global(name: "gbBCPD", address: 0xff69, dataType: "hex"),
      Global(name: "gbOCPS", address: 0xff6a, dataType: "hex"),
      Global(name: "gbOCPD", address: 0xff6b, dataType: "hex"),
      Global(name: "gbSVBK", address: 0xff70, dataType: "hex"),
      Global(name: "gbPCM12", address: 0xff76, dataType: "hex"),
      Global(name: "gbPCM34", address: 0xff77, dataType: "hex"),
      Global(name: "gbIE", address: 0xffff, dataType: "HW_IE"),
    ])

    self.init(rom: rom, scripts: [], macros: [], globals: globals, dataTypes: dataTypes, regions: regions)
  }
}

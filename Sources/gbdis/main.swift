import Foundation
import LR35902



let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"))

let disassembly = LR35902.Disassembly(rom: data)

func extractText(from range: Range<LR35902.CartridgeLocation>) {
  let parts = data[range].split(separator: 0xff, maxSplits: .max, omittingEmptySubsequences: false)
  let addressAndBank = LR35902.addressAndBank(from: range.lowerBound)
  var offset: LR35902.Address = addressAndBank.address
  for (index, part) in parts.enumerated() {
    let textRange = offset..<(offset + LR35902.Address(part.count))
    disassembly.setText(at: textRange, in: addressAndBank.bank, lineLength: 16)
    if index != parts.endIndex {
      disassembly.setData(at: textRange.upperBound, in: addressAndBank.bank)
    }
    offset += LR35902.Address(part.count + 1)
  }
}

var jumpTableIndex = 0

func disassembleJumpTable(within range: Range<LR35902.Address>, in bank: LR35902.Bank,
                          selectedBank: LR35902.Bank? = nil,
                          bankTable: [UInt8: LR35902.Bank]? = nil,
                          functionNames: [UInt8: String]? = nil) {
//  assert((range.upperBound - range.lowerBound) <= 256)
  jumpTableIndex += 1
  disassembly.setJumpTable(at: range, in: bank)

  let bankSelector: (UInt8) -> LR35902.Bank?
  if let selectedBank = selectedBank {
    disassembly.register(bankChange: selectedBank, at: range.lowerBound - 1, in: bank)
    bankSelector = { _ in
      selectedBank
    }
  } else if let bankTable = bankTable {
    bankSelector = {
      bankTable[$0]
    }
  } else {
    return
  }
  let cartRange = LR35902.cartAddress(for: range.lowerBound, in: bank)!..<LR35902.cartAddress(for: range.upperBound, in: bank)!
  for location in stride(from: cartRange.lowerBound, to: cartRange.upperBound, by: 2) {
    let lowByte = data[Int(location)]
    let highByte = data[Int(location + 1)]
    let address: LR35902.Address = (LR35902.Address(highByte) << 8) | LR35902.Address(lowByte)
    if address < 0x8000 {
      let index = UInt8((location - cartRange.lowerBound) / 2)
      let effectiveBank: LR35902.Bank
      let addressAndBank = LR35902.addressAndBank(from: location)
      if address < 0x4000 {
        effectiveBank = 0
      } else {
        guard let selectedBank = bankSelector(index) else {
          continue
        }
        disassembly.register(bankChange: selectedBank, at: addressAndBank.address, in: bank)
        effectiveBank = selectedBank
      }
      if effectiveBank == 0 && address >= 0x4000 {
        continue // Don't disassemble if we're not confident what the bank is.
      }
      let name: String
      if let functionName = functionNames?[index] {
        name = functionName
      } else {
        name = "JumpTable_\(address.hexString)_\(effectiveBank.hexString)"
      }
      disassembly.registerTransferOfControl(to: address, in: effectiveBank, from: addressAndBank.address, in: addressAndBank.bank, spec: .jp(nil, .imm16))
      disassembly.defineFunction(startingAt: address, in: effectiveBank, named: name)
    }
  }
}

disassembly.createDatatype(named: "GAMEMODE", enumeration: [
  0x00: "GAMEMODE_INTRO",
  0x01: "GAMEMODE_CREDITS",
  0x02: "GAMEMODE_FILE_SELECT",
  0x03: "GAMEMODE_FILE_NEW",
  0x04: "GAMEMODE_FILE_DELETE",
  0x05: "GAMEMODE_FILE_COPY",
  0x06: "GAMEMODE_FILE_SAVE",
  0x07: "GAMEMODE_MINI_MAP",
  0x08: "GAMEMODE_PEACH_PIC",
  0x09: "GAMEMODE_MARIN_BEACH",
  0x0a: "GAMEMODE_WF_MURAL",
  0x0b: "GAMEMODE_WORLD",
  0x0c: "GAMEMODE_INVENTORY",
  0x0d: "GAMEMODE_PHOTO_ALBUM",
  0x0e: "GAMEMODE_PHOTO_DIZZY_LINK",
  0x0f: "GAMEMODE_PHOTO_NICE_LINK",
  0x10: "GAMEMODE_PHOTO_MARIN_CLIFF",
  0x11: "GAMEMODE_PHOTO_MARIN_WELL",
  0x12: "GAMEMODE_PHOTO_MABE",
  0x13: "GAMEMODE_PHOTO_ULRIRA",
  0x14: "GAMEMODE_PHOTO_BOW_WOW",
  0x15: "GAMEMODE_PHOTO_THIEF",
  0x16: "GAMEMODE_PHOTO_FISHERMAN",
  0x17: "GAMEMODE_PHOTO_ZORA",
  0x18: "GAMEMODE_PHOTO_KANALET",
  0x19: "GAMEMODE_PHOTO_GHOST",
  0x20: "GAMEMODE_PHOTO_BRIDGE",
])

disassembly.createDatatype(named: "ENTITY", enumeration: [
  0x00: "ENTITY_ARROW",
  0x01: "ENTITY_BOOMERANG",
  0x02: "ENTITY_BOMB",
  0x03: "ENTITY_HOOKSHOT_CHAIN",
  0x04: "ENTITY_HOOKSHOT_HIT",
  0x05: "ENTITY_ENTITY_LIFTABLE_ROCK",
  0x06: "ENTITY_PUSHED_BLOCK",
  0x07: "ENTITY_CHEST_WITH_ITEM",
  0x08: "ENTITY_MAGIC_POWDER_SPRINKLE",
  0x09: "ENTITY_OCTOROCK",
  0x0A: "ENTITY_OCTOROCK_ROCK",
  0x0B: "ENTITY_MOBLIN",
  0x0C: "ENTITY_MOBLIN_ARROW",
  0x0D: "ENTITY_TEKTITE",
  0x0E: "ENTITY_LEEVER",
  0x0F: "ENTITY_ARMOS_STATUE",
  0x10: "ENTITY_HIDING_GHINI",
  0x11: "ENTITY_GIANT_GHINI",
  0x12: "ENTITY_GHINI",
  0x13: "ENTITY_BROKEN_HEART_CONTAINER",
  0x14: "ENTITY_MOBLIN_SWORD",
  0x15: "ENTITY_ANTI_FAIRY",
  0x16: "ENTITY_SPARK_COUNTER_CLOCKWISE",
  0x17: "ENTITY_SPARK_CLOCKWISE",
  0x18: "ENTITY_POLS_VOICE",
  0x19: "ENTITY_KEESE",
  0x1A: "ENTITY_STALFOS_AGGRESSIVE",
  0x1B: "ENTITY_GEL",
  0x1C: "ENTITY_MINI_GEL",
  0x1D: "ENTITY_1D",
  0x1E: "ENTITY_STALFOS_EVASIVE",
  0x1F: "ENTITY_GIBDO",
  0x20: "ENTITY_HARDHAT_BEETLE",
  0x21: "ENTITY_WIZROBE",
  0x22: "ENTITY_WIZROBE_PROJECTILE",
  0x23: "ENTITY_LIKE_LIKE",
  0x24: "ENTITY_IRON_MASK",
  0x25: "ENTITY_SMALL_EXPLOSION_ENEMY",
  0x26: "ENTITY_SMALL_EXPLOSION_ENEMY_2",
  0x27: "ENTITY_SPIKE_TRAP",
  0x28: "ENTITY_MIMIC",
  0x29: "ENTITY_MINI_MOLDORM",
  0x2A: "ENTITY_LASER",
  0x2B: "ENTITY_LASER_BEAM",
  0x2C: "ENTITY_SPIKED_BEETLE",
  0x2D: "ENTITY_DROPPABLE_HEART",
  0x2E: "ENTITY_DROPPABLE_RUPEE",
  0x2F: "ENTITY_DROPPABLE_FAIRY",
  0x30: "ENTITY_KEY_DROP_POINT",
  0x31: "ENTITY_SWORD",
  0x32: "ENTITY_32",
  0x33: "ENTITY_PIECE_OF_POWER",
  0x34: "ENTITY_GUARDIAN_ACORN",
  0x35: "ENTITY_HEART_PIECE",
  0x36: "ENTITY_HEART_CONTAINER",
  0x37: "ENTITY_DROPPABLE_ARROWS",
  0x38: "ENTITY_DROPPABLE_BOMBS",
  0x39: "ENTITY_INSTRUMENT_OF_THE_SIRENS",
  0x3A: "ENTITY_SLEEPY_TOADSTOOL",
  0x3B: "ENTITY_DROPPABLE_MAGIC_POWDER",
  0x3C: "ENTITY_HIDING_SLIME_KEY",
  0x3D: "ENTITY_DROPPABLE_SECRET_SEASHELL",
  0x3E: "ENTITY_MARIN",
  0x3F: "ENTITY_RACOON",
  0x40: "ENTITY_WITCH",
  0x41: "ENTITY_OWL_EVENT",
  0x42: "ENTITY_OWL_STATUE",
  0x43: "ENTITY_SEASHELL_MANSION_TREES",
  0x44: "ENTITY_YARNA_TALKING_BONES",
  0x45: "ENTITY_BOULDERS",
  0x46: "ENTITY_MOVING_BLOCK_LEFT_TOP",
  0x47: "ENTITY_MOVING_BLOCK_LEFT_BOTTOM",
  0x48: "ENTITY_MOVING_BLOCK_BOTTOM_LEFT",
  0x49: "ENTITY_MOVING_BLOCK_BOTTOM_RIGHT",
  0x4A: "ENTITY_COLOR_DUNGEON_BOOK",
  0x4B: "ENTITY_POT",
  0x4C: "ENTITY_4C",
  0x4D: "ENTITY_SHOP_OWNER",
  0x4E: "ENTITY_4E",
  0x4F: "ENTITY_TRENDY_GAME_OWNER",
  0x50: "ENTITY_BOO_BUDDY",
  0x51: "ENTITY_KNIGHT",
  0x52: "ENTITY_TRACTOR_DEVICE",
  0x53: "ENTITY_TRACTOR_DEVICE_REVERSE",
  0x54: "ENTITY_FISHERMAN_FISHING_GAME",
  0x55: "ENTITY_BOUNCING_BOMBITE",
  0x56: "ENTITY_TIMER_BOMBITE",
  0x57: "ENTITY_PAIRODD",
  0x58: "ENTITY_58",
  0x59: "ENTITY_MOLDORM",
  0x5A: "ENTITY_FACADE",
  0x5B: "ENTITY_SLIME_EYE",
  0x5C: "ENTITY_GENIE",
  0x5D: "ENTITY_SLIME_EEL",
  0x5E: "ENTITY_GHOMA",
  0x5F: "ENTITY_MASTER_STALFOS",
  0x60: "ENTITY_DODONGO_SNAKE",
  0x61: "ENTITY_WARP",
  0x62: "ENTITY_HOT_HEAD",
  0x63: "ENTITY_EVIL_EAGLE",
  0x64: "ENTITY_64",
  0x65: "ENTITY_ANGLER_FISH",
  0x66: "ENTITY_CRYSTAL_SWITCH",
  0x67: "ENTITY_67",
  0x68: "ENTITY_68",
  0x69: "ENTITY_MOVING_BLOCK_MOVER",
  0x6A: "ENTITY_RAFT_OWNER",
  0x6B: "ENTITY_TEXT_DEBUGGER",
  0x6C: "ENTITY_CUCCO",
  0x6D: "ENTITY_BOW_WOW",
  0x6E: "ENTITY_BUTTERFLY",
  0x6F: "ENTITY_DOG",
  0x70: "ENTITY_KID_70",
  0x71: "ENTITY_KID_71",
  0x72: "ENTITY_KID_72",
  0x73: "ENTITY_KID_73",
  0x74: "ENTITY_PAPAHLS_WIFE",
  0x75: "ENTITY_GRANDMA_ULRIRA",
  0x76: "ENTITY_MR_WRITE",
  0x77: "ENTITY_GRANDPA_ULRIRA",
  0x78: "ENTITY_YIP_YIP",
  0x79: "ENTITY_MADAM_MEOWMEOW",
  0x7A: "ENTITY_CROW",
  0x7B: "ENTITY_CRAZY_TRACY",
  0x7C: "ENTITY_GIANT_GOPONGA_FLOWER",
  0x7D: "ENTITY_GOPONGA_FLOWER_PROJECTILE",
  0x7E: "ENTITY_GOPONGA_FLOWER",
  0x7F: "ENTITY_TURTLE_ROCK_HEAD",
  0x80: "ENTITY_TELEPHONE",
  0x81: "ENTITY_ROLLING_BONES",
  0x82: "ENTITY_ROLLING_BONES_BAR",
  0x83: "ENTITY_DREAM_SHRINE_BED",
  0x84: "ENTITY_BIG_FAIRY",
  0x85: "ENTITY_MR_WRITES_BIRD",
  0x86: "ENTITY_FLOATING_ITEM",
  0x87: "ENTITY_DESERT_LANMOLA",
  0x88: "ENTITY_ARMOS_KNIGHT",
  0x89: "ENTITY_HINOX",
  0x8A: "ENTITY_TILE_GLINT_SHOWN",
  0x8B: "ENTITY_TILE_GLINT_HIDDEN",
  0x8C: "ENTITY_8C",
  0x8D: "ENTITY_8D",
  0x8E: "ENTITY_CUE_BALL",
  0x8F: "ENTITY_MASKED_MIMIC_GORIYA",
  0x90: "ENTITY_THREE_OF_A_KIND",
  0x91: "ENTITY_ANTI_KIRBY",
  0x92: "ENTITY_SMASHER",
  0x93: "ENTITY_MAD_BOMBER",
  0x94: "ENTITY_KANALET_BOMBABLE_WALL",
  0x95: "ENTITY_RICHARD",
  0x96: "ENTITY_RICHARD_FROG",
  0x97: "ENTITY_97",
  0x98: "ENTITY_HORSE_PIECE",
  0x99: "ENTITY_WATER_TEKTITE",
  0x9A: "ENTITY_FLYING_TILES",
  0x9B: "ENTITY_HIDING_GEL",
  0x9C: "ENTITY_STAR",
  0x9D: "ENTITY_LIFTABLE_STATUE",
  0x9E: "ENTITY_FIREBALL_SHOOTER",
  0x9F: "ENTITY_GOOMBA",
  0xA0: "ENTITY_PEAHAT",
  0xA1: "ENTITY_SNAKE",
  0xA2: "ENTITY_PIRANHA_PLANT",
  0xA3: "ENTITY_SIDE_VIEW_PLATFORM_HORIZONTAL",
  0xA4: "ENTITY_SIDE_VIEW_PLATFORM_VERTICAL",
  0xA5: "ENTITY_SIDE_VIEW_PLATFORM",
  0xA6: "ENTITY_SIDE_VIEW_WEIGHTS",
  0xA7: "ENTITY_SMASHABLE_PILLAR",
  0xA8: "ENTITY_A8",
  0xA9: "ENTITY_BLOOPER",
  0xAA: "ENTITY_CHEEP_CHEEP_HORIZONTAL",
  0xAB: "ENTITY_CHEEP_CHEEP_VERTICAL",
  0xAC: "ENTITY_CHEEP_CHEEP_JUMPING",
  0xAD: "ENTITY_KIKI_THE_MONKEY",
  0xAE: "ENTITY_WINGED_OCTOROK",
  0xAF: "ENTITY_TRADING_ITEM",
  0xB0: "ENTITY_PINCER",
  0xB1: "ENTITY_HOLE_FILLER",
  0xB2: "ENTITY_BEETLE_SPAWNER",
  0xB3: "ENTITY_HONEYCOMB",
  0xB4: "ENTITY_TARIN",
  0xB5: "ENTITY_BEAR",
  0xB6: "ENTITY_PAPAHL",
  0xB7: "ENTITY_MERMAID",
  0xB8: "ENTITY_FISHERMAN_UNDER_BRIDGE",
  0xB9: "ENTITY_BUZZ_BLOB",
  0xBA: "ENTITY_BOMBER",
  0xBB: "ENTITY_BUSH_CRAWLER",
  0xBC: "ENTITY_GRIM_CREEPER",
  0xBD: "ENTITY_VIRE",
  0xBE: "ENTITY_BLAINO",
  0xBF: "ENTITY_ZOMBIES",
  0xC0: "ENTITY_MAZE_SIGNPOST",
  0xC1: "ENTITY_MARIN_AT_THE_SHORE",
  0xC2: "ENTITY_MARIN_AT_TAL_TAL_HEIGHTS",
  0xC3: "ENTITY_MAMU_AND_FROGS",
  0xC4: "ENTITY_WALRUS",
  0xC5: "ENTITY_URCHIN",
  0xC6: "ENTITY_SAND_CRAB",
  0xC7: "ENTITY_MANBO_AND_FISHES",
  0xC8: "ENTITY_BUNNY_CALLS_MARIN",
  0xC9: "ENTITY_MUSICAL_NOTE",
  0xCA: "ENTITY_MAD_BATTER",
  0xCB: "ENTITY_ZORA",
  0xCC: "ENTITY_FISH",
  0xCD: "ENTITY_BANANAS_SCHULE_SALE",
  0xCE: "ENTITY_MERMAID_STATUE",
  0xCF: "ENTITY_SEASHELL_MANSION",
  0xD0: "ENTITY_ANIMAL_D0",
  0xD1: "ENTITY_ANIMAL_D1",
  0xD2: "ENTITY_ANIMAL_D2",
  0xD3: "ENTITY_BUNNY_D3",
  0xD4: "ENTITY_D4",
  0xD5: "ENTITY_D5",
  0xD6: "ENTITY_SIDE_VIEW_POT",
  0xD7: "ENTITY_THWIMP",
  0xD8: "ENTITY_THWOMP",
  0xD9: "ENTITY_THWOMP_RAMMABLE",
  0xDA: "ENTITY_PODOBOO",
  0xDB: "ENTITY_GIANT_BUBBLE",
  0xDC: "ENTITY_FLYING_ROOSTER_EVENTS",
  0xDD: "ENTITY_BOOK",
  0xDE: "ENTITY_EGG_SONG_EVENT",
  0xDF: "ENTITY_SWORD_BEAM",
  0xE0: "ENTITY_MONKEY",
  0xE1: "ENTITY_WITCH_RAT",
  0xE2: "ENTITY_FLAME_SHOOTER",
  0xE3: "ENTITY_POKEY",
  0xE4: "ENTITY_MOBLIN_KING",
  0xE5: "ENTITY_FLOATING_ITEM_2",
  0xE6: "ENTITY_FINAL_NIGHTMARE",
  0xE7: "ENTITY_KANLET_CASTLE_GATE_SWITCH",
  0xE8: "ENTITY_ENDING_OWL_STAIR_CLIMBING",
  0xE9: "ENTITY_COLOR_SHELL_RED",
  0xEA: "ENTITY_COLOR_SHELL_GREEN",
  0xEB: "ENTITY_COLOR_SHELL_BLUE",
  0xEC: "ENTITY_COLOR_GHOUL_RED",
  0xED: "ENTITY_COLOR_GHOUL_GREEN",
  0xEE: "ENTITY_COLOR_GHOUL_BLUE",
  0xEF: "ENTITY_ROTOSWITCH_RED",
  0xF0: "ENTITY_ROTOSWITCH_YELLOW",
  0xF1: "ENTITY_ROTOSWITCH_BLUE",
  0xF2: "ENTITY_FLYING_HOPPER_BOMBS",
  0xF3: "ENTITY_HOPPER",
  0xF4: "ENTITY_GOLEM_BOSS",
  0xF5: "ENTITY_BOUNCING_BOULDER",
  0xF6: "ENTITY_COLOR_GUARDIAN_BLUE",
  0xF7: "ENTITY_COLOR_GUARDIAN_RED",
  0xF8: "ENTITY_GIANT_BUZZ_BLOB",
  0xF9: "ENTITY_COLOR_DUNGEON_BOSS",
  0xFA: "ENTITY_PHOTOGRAPHER_RELATED",
  0xFB: "ENTITY_FB",
  0xFC: "ENTITY_FC",
  0xFD: "ENTITY_FD",
  0xFE: "ENTITY_FE",
  0xFF: "ENTITY_FF",
])

disassembly.createDatatype(named: "DIRECTION", enumeration: [
  0: "DIRECTION_RIGHT",
  1: "DIRECTION_LEFT",
  2: "DIRECTION_UP",
  3: "DIRECTION_DOWN",
])

disassembly.createDatatype(named: "ROOM_STATUS", bitmask: [
  0x00: "ROOM_STATUS_NOT_VISITED",
  0x80: "ROOM_STATUS_VISITED",
])

disassembly.createDatatype(named: "SCROLL_VIEW", enumeration: [
  0: "SCROLL_VIEW_TOP",
  2: "SCROLL_VIEW_SIDE",
])

disassembly.createDatatype(named: "TRACK", enumeration: [
  0x00: "TRACK_NONE",
  0x01: "TRACK_TITLE_SCREEN",
  0x02: "TRACK_TRENDY_GAME",
  0x03: "TRACK_GAME_OVER",
  0x04: "TRACK_MABE_VILLAGE",
  0x05: "TRACK_OVERWORLD",
  0x06: "TRACK_TAL_TAL_HEIGHTS",
  0x07: "TRACK_VILLAGE_SHOP",
  0x08: "TRACK_RAFT_RIDE_RAPIDS",
  0x09: "TRACK_MYSTERIOUS_FOREST",
  0x0A: "TRACK_HOME_TRADER_HOUSE",
  0x0B: "TRACK_ANIMAL_VILLAGE",
  0x0C: "TRACK_FAIRY_HOUSE",
  0x0D: "TRACK_TITLE",
  0x0E: "TRACK_BOWWOW_KIDNAPPED",
  0x0F: "TRACK_FOUND_LEVEL_2_SWORD",
  0x10: "TRACK_FOUND_NEW_WEAPON",
  0x11: "TRACK_2D_UNDERGROUND_DUNGEON",
  0x12: "TRACK_OWL",
  0x13: "TRACK_FINAL_NIGHTMARE_IN_EGG",
  0x14: "TRACK_DREAM_SHRINE_ENTRANCE",
  0x15: "TRACK_FOUND_INSTRUMENT",
  0x16: "TRACK_OVERWORLD_CAVE",
  0x17: "TRACK_PIECE_OF_POWER",
  0x18: "TRACK_RECEIVED_HORN_INSTRUMENT",
  0x19: "TRACK_RECEIVED_BELL_INSTRUMENT",
  0x1A: "TRACK_RECEIVED_HARP_INSTRUMENT",
  0x1B: "TRACK_RECEIVED_XYLOPHONE_INSTRUMENT",
  0x1C: "TRACK_1C",
  0x1D: "TRACK_1D",
  0x1E: "TRACK_RECEIVED_THUNDER_DRUM_INSTRUMENT",
  0x1F: "TRACK_MARIN_SINGING",
  0x20: "TRACK_MANBO_SONG",
  0x21: "TRACK_21",
  0x22: "TRACK_22",
  0x23: "TRACK_23",
  0x24: "TRACK_24",
  0x25: "TRACK_COMPLETE_INSTRUMENTS_SONG_PART_1",
  0x26: "TRACK_COMPLETE_INSTRUMENTS_SONG_PART_2",
  0x27: "TRACK_27",
  0x28: "TRACK_LONELY_HOUSE",
  0x29: "TRACK_PIECE_OF_POWER_PART_2",
  0x2A: "TRACK_MARIN_SINGING_LINKS_OCARINA",
  0x2B: "TRACK_LEVEL_5",
  0x2C: "TRACK_DUNGEON_ENTRANCE_UNLOCKING",
  0x2D: "TRACK_DREAM_SEQUENCE_SOUND",
  0x2E: "TRACK_AT_BEACH_WITH_MARIN",
  0x2F: "TRACK_UNKNOWN",
  0x30: "TRACK_DUNGEON_SUB_BOSS",
  0x31: "TRACK_RECEIVED_LEVEL_1_SWORD",
  0x32: "TRACK_MR_WRITE_HOUSE",
  0x33: "TRACK_ULRIRA_HOUSE",
  0x34: "TRACK_TARIN_ATTACKED_BY_BEES",
  0x35: "TRACK_MAMU_SONG",
  0x36: "TRACK_MONKEYS_BUILDING_BRIDGE",
  0x37: "TRACK_MR_WRITE_HOUSE_VERSION_2",
  0x38: "TRACK_RICHARD_HOUSE_SECRET_SONG",
  0x39: "TRACK_TURTLE_ROCK_ENTRANCE_BOSS",
  0x3A: "TRACK_FISHING_GAME",
  0x3B: "TRACK_RECEIVED_ITEM",
  0x3C: "TRACK_HIDDEN_UNUSED_SONG",
  0x3D: "TRACK_NOTHING",
  0x3E: "TRACK_BOWWOW_STOLEN",
  0x3F: "TRACK_ENDING",
  0x40: "TRACK_RICHARD_HOUSE",
  0x41: "TRACK_41",
  0x42: "TRACK_42",
  0x43: "TRACK_43",
  0x44: "TRACK_44",
  0x45: "TRACK_45",
  0x46: "TRACK_46",
  0x47: "TRACK_47",
  0x48: "TRACK_48",
  0x49: "TRACK_ACTIVE_POWER_UP",
  0x4A: "TRACK_4A",
  0x4B: "TRACK_4B",
  0x4C: "TRACK_4C",
  0x4D: "TRACK_4D",
  0x50: "TRACK_50",
  0x58: "TRACK_58",
  0x59: "TRACK_59",
  0x5A: "TRACK_5A",
  0x5B: "TRACK_5B",
  0x5C: "TRACK_5C",
  0x5D: "TRACK_5D",
  0x5E: "TRACK_5E",
  0x5F: "TRACK_5F",
  0x60: "TRACK_60",
  0x61: "TRACK_COLOR_DUNGEON",
  0x6A: "TRACK_6A",
  0xF0: "TRACK_F0",
  0xFF: "TRACK_FF",
])

disassembly.setData(at: 0x0004..<0x0008, in: 0x00)

let numberOfRestartAddresses: LR35902.Address = 8
let restartSize: LR35902.Address = 8
let rstAddresses = (1..<numberOfRestartAddresses).map { ($0 * restartSize)..<($0 * restartSize + restartSize) }
rstAddresses.forEach {
  disassembly.setData(at: $0, in: 0x00)
}


disassembly.createGlobal(at: 0x0003, named: "DEBUG_TOOL", dataType: "bool")
disassembly.createGlobal(at: 0xa100, named: "SAVEFILES")
disassembly.createGlobal(at: 0xc10e, named: "wNeedsNPCTilesUpdate", dataType: "bool")
disassembly.createGlobal(at: 0xc124, named: "wRoomTransitionState")
disassembly.createGlobal(at: 0xc125, named: "wRoomTransitionDirection")
disassembly.createGlobal(at: 0xc155, named: "wScreenShakeHorizontal")
disassembly.createGlobal(at: 0xc156, named: "wScreenShakeVertical")
disassembly.createGlobal(at: 0xc1bf, named: "wScrollXOffset")
disassembly.createGlobal(at: 0xc500, named: "wAlternateBackgroundEnabled")
disassembly.createGlobal(at: 0xd369, named: "wAudioData")
disassembly.createGlobal(at: 0xd379, named: "wAudioSelection")
disassembly.createGlobal(at: 0xd46c, named: "wBossDefeated", dataType: "bool")
disassembly.createGlobal(at: 0xd6fc, named: "wEnginePaused", dataType: "bool")
disassembly.createGlobal(at: 0xd6fd, named: "wLCDControl", dataType: "LCDCF")
disassembly.createGlobal(at: 0xd6fe, named: "wTileMapToLoad")
disassembly.createGlobal(at: 0xd6ff, named: "wBGMapToLoad")
disassembly.createGlobal(at: 0xdb95, named: "wGameMode", dataType: "GAMEMODE")
disassembly.createGlobal(at: 0xdb96, named: "wGameSubMode")
disassembly.createGlobal(at: 0xdbaf, named: "wCurrentBank")
disassembly.createGlobal(at: 0xff80, named: "hRomBank")
disassembly.createGlobal(at: 0xff81, named: "hTemp")
disassembly.createGlobal(at: 0xff82, named: "hCodeTemp")
disassembly.createGlobal(at: 0xff90, named: "hNeedsBGTilesUpdate", dataType: "bool")
disassembly.createGlobal(at: 0xff91, named: "hNeedsEnemyTilesUpdate", dataType: "bool")
disassembly.createGlobal(at: 0xff96, named: "hBaseScrollX", dataType: "decimal")
disassembly.createGlobal(at: 0xff97, named: "hBaseScrollY", dataType: "decimal")
disassembly.createGlobal(at: 0xff98, named: "hLinkX", dataType: "decimal")
disassembly.createGlobal(at: 0xff99, named: "hLinkY", dataType: "decimal")
disassembly.createGlobal(at: 0xff9a, named: "hLinkXDelta", dataType: "decimal")
disassembly.createGlobal(at: 0xff9b, named: "hLinkYDelta", dataType: "decimal")
disassembly.createGlobal(at: 0xff9d, named: "hLinkAnimationState")
disassembly.createGlobal(at: 0xff9e, named: "hLinkDirection", dataType: "DIRECTION")
disassembly.createGlobal(at: 0xff9f, named: "hLinkXFinal", dataType: "decimal")
disassembly.createGlobal(at: 0xffa0, named: "hLinkYFinal", dataType: "decimal")
disassembly.createGlobal(at: 0xffa9, named: "hWindowY")
disassembly.createGlobal(at: 0xffaa, named: "hWindowX")
disassembly.createGlobal(at: 0xffb0, named: "hMusicTrack", dataType: "TRACK")
disassembly.createGlobal(at: 0xffb5, named: "hButtonsInactiveDelay", dataType: "decimal")
disassembly.createGlobal(at: 0xffcb, named: "hPreviousJoypadState", dataType: "BUTTON")
disassembly.createGlobal(at: 0xffcc, named: "hJoypadState", dataType: "BUTTON")
disassembly.createGlobal(at: 0xffd7, named: "hScratchA")
disassembly.createGlobal(at: 0xffd8, named: "hScratchB")
disassembly.createGlobal(at: 0xffd9, named: "hScratchC")
disassembly.createGlobal(at: 0xffda, named: "hScratchD")
disassembly.createGlobal(at: 0xffea, named: "hActiveEntityState")
disassembly.createGlobal(at: 0xffeb, named: "hActiveEntityType", dataType: "ENTITY")
disassembly.createGlobal(at: 0xffe7, named: "hFrameCounter")
disassembly.createGlobal(at: 0xffd1, named: "hNeedsRenderingFrame")
disassembly.createGlobal(at: 0xfff7, named: "hMapID")
disassembly.createGlobal(at: 0xfff8, named: "hRoomStatus", dataType: "ROOM_STATUS")
disassembly.createGlobal(at: 0xfff9, named: "hIsSideScrolling", dataType: "SCROLL_VIEW")
disassembly.createGlobal(at: 0xfffa, named: "hLinkRoomPosition", dataType: "decimal")
disassembly.createGlobal(at: 0xfffb, named: "hLinkFinalRoomPosition", dataType: "decimal")
disassembly.createGlobal(at: 0xfffd, named: "hDidRenderFrame", dataType: "bool")

disassembly.setSoftTerminator(at: 0x05F1, in: 0x00) // This function can't logically proceed past this point.

disassembly.setData(at: 0x4000..<(0x4000 + 0x0400), in: 0x0C)
disassembly.setData(at: 0x4000..<(0x4000 + 0x0400), in: 0x0F)
disassembly.setData(at: 0x4000..<(0x4000 + 0x0600), in: 0x0D)
disassembly.setData(at: 0x4000..<(0x4000 + 0x1000), in: 0x10)
disassembly.setData(at: 0x4000..<(0x4000 + 0x1800), in: 0x13)
disassembly.setData(at: 0x4220..<(0x4220 + 0x0020), in: 0x0C)
disassembly.setData(at: 0x4400..<(0x4400 + 0x0500), in: 0x0F)
disassembly.setData(at: 0x47A0..<(0x47A0 + 0x0020), in: 0x0C)
disassembly.setData(at: 0x47C0..<(0x47C0 + 0x0040), in: 0x0C)
disassembly.setData(at: 0x4800..<(0x4800 + 0x1000), in: 0x0C)
disassembly.setData(at: 0x4900..<(0x4900 + 0x0700), in: 0x0F)
disassembly.setData(at: 0x4C00..<(0x4C00 + 0x0400), in: 0x0C)
disassembly.setData(at: 0x5000..<(0x5000 + 0x0100), in: 0x0C)
disassembly.setData(at: 0x5000..<(0x5000 + 0x0800), in: 0x0C)
disassembly.setData(at: 0x5000..<(0x5000 + 0x0800), in: 0x0F)
disassembly.setData(at: 0x5200..<(0x5200 + 0x0600), in: 0x0C)
disassembly.setData(at: 0x5400..<(0x5400 + 0x0600), in: 0x10)
disassembly.setData(at: 0x57E0..<(0x57E0 + 0x0010), in: 0x0C)
disassembly.setData(at: 0x5800..<(0x5800 + 0x1000), in: 0x13)
disassembly.setData(at: 0x5919..<(0x5919 + 0x0010), in: 0x05)
disassembly.setData(at: 0x5939..<(0x5939 + 0x0010), in: 0x05)
disassembly.setData(at: 0x6000..<(0x6000 + 0x0600), in: 0x10)
disassembly.setData(at: 0x6000..<(0x6000 + 0x0800), in: 0x0F)
disassembly.setData(at: 0x6000..<(0x6000 + 0x0800), in: 0x12)
disassembly.setData(at: 0x6600..<(0x6600 + 0x0080), in: 0x12)
disassembly.setData(at: 0x6700..<(0x6700 + 0x0400), in: 0x10)
disassembly.setData(at: 0x6800..<(0x6800 + 0x0400), in: 0x13)
disassembly.setData(at: 0x6800..<(0x6800 + 0x0800), in: 0x13)
disassembly.setData(at: 0x6800..<(0x6800 + 0x0800), in: 0x13)
disassembly.setData(at: 0x7000..<(0x7000 + 0x0800), in: 0x13)
disassembly.setData(at: 0x7000..<(0x7000 + 0x0800), in: 0x13)
disassembly.setData(at: 0x7500..<(0x7500 + 0x0040), in: 0x12)
disassembly.setData(at: 0x7500..<(0x7500 + 0x0200), in: 0x12)
disassembly.setData(at: 0x7D31..<(0x7D31 + 0x0080), in: 0x01)

// MARK: - Jump tables

disassembleJumpTable(within: 0x04b3..<0x04F5, in: 0x00, selectedBank: 0x00)
disassembleJumpTable(within: 0x1b6e..<0x1b90, in: 0x00, selectedBank: 0x00)

disassembleJumpTable(within: 0x0ad2..<0x0aea, in: 0x00, selectedBank: 0x00)
disassembleJumpTable(within: 0x215f..<0x217d, in: 0x00, selectedBank: 0x00)

disassembleJumpTable(within: 0x0c82..<0x0C8C, in: 0x00, selectedBank: 0x01)
disassembleJumpTable(within: 0x0d33..<0x0d49, in: 0x00, selectedBank: 0x03)  // TODO: This may be called with different banks.
disassembleJumpTable(within: 0x30fb..<0x310d, in: 0x00, selectedBank: 0x00)
disassembleJumpTable(within: 0x3114..<0x3138, in: 0x00, selectedBank: 0x00)
disassembleJumpTable(within: 0x392b..<0x393d, in: 0x00, selectedBank: 0x03)

disassembleJumpTable(within: 0x4187..<0x4191, in: 0x01, selectedBank: 0x01)
disassembleJumpTable(within: 0x4322..<0x4332, in: 0x01, selectedBank: 0x01)

disassembleJumpTable(within: 0x5378..<0x5392, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x5b2f..<0x5b3f, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x5d45..<0x5d63, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x6b4e..<0x6b56, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x6b74..<0x6b7c, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x6b9a..<0x6ba2, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x6c1f..<0x6c25, in: 0x02, selectedBank: 0x02)
disassembleJumpTable(within: 0x7c53..<0x7c5d, in: 0x02, selectedBank: 0x02)

disassembleJumpTable(within: 0x4976..<(0x4976 + 233 * 2), in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5aa6..<0x5ab8, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5bf5..<0x5bfd, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5de0..<0x5de6, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5e43..<0x5e53, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x5ef7..<0x5f01, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x6353..<0x6375, in: 0x03, selectedBank: 0x03)
disassembleJumpTable(within: 0x700b..<0x7017, in: 0x03, selectedBank: 0x03)

disassembleJumpTable(within: 0x4015..<0x401f, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4091..<0x4099, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x42e5..<0x42eb, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4328..<0x4334, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x49d0..<0x49d4, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x49dd..<0x49e5, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4b52..<0x4b56, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4e0d..<0x4e13, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x4e8c..<0x4e94, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x5078..<0x5080, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x50a1..<0x50a7, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x512f..<0x5135, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x553f..<0x5545, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x55b0..<0x55b6, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x56bd..<0x56C5, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x5E23..<0x5E29, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x5FCF..<0x5FD5, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x6081..<0x6089, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x6802..<0x6806, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x69B0..<0x69B6, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x6EB6..<0x6ED0, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x747B..<0x7487, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x76B4..<0x76c2, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x79E5..<0x79F7, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x7CCE..<0x7CD2, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x7DA6..<0x7DAC, in: 0x04, selectedBank: 0x04)
disassembleJumpTable(within: 0x7E82..<0x7E8A, in: 0x04, selectedBank: 0x04)

disassembleJumpTable(within: 0x40AE..<0x40B2, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x4169..<0x4173, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x461E..<0x4626, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x47F9..<0x4803, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x4988..<0x4990, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x4BFF..<0x4C09, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x4EB7..<0x4EC3, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x51A4..<0x51AA, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x52C4..<0x52CA, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x5395..<0x539B, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x54B0..<0x54B8, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x54CD..<0x54D1, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x5625..<0x562B, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x59C1..<0x59C9, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x59CC..<0x59D6, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x5AFA..<0x5B18, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x5C64..<0x5C6E, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x61BD..<0x61C1, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x6224..<0x6228, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x628B..<0x628F, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x62CD..<0x62D9, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x6C5D..<0x6C65, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x7210..<0x721A, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x6701..<0x6705, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x67E9..<0x67EF, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x6C50..<0x6C56, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x7B4E..<0x7B56, in: 0x05, selectedBank: 0x05)
disassembleJumpTable(within: 0x7D93..<0x7D99, in: 0x05, selectedBank: 0x05)

disassembleJumpTable(within: 0x404C..<0x4056, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4172..<0x417C, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x426E..<0x4278, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4585..<0x458F, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x47F8..<0x4802, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4964..<0x496A, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4AE0..<0x4AE8, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x4BFC..<0x4C00, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5143..<0x514F, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x53D1..<0x53D9, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x54DB..<0x54EB, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x56EE..<0x56F6, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5824..<0x5834, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5B71..<0x5B79, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5DA6..<0x5DAE, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x5F6A..<0x5F74, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6117..<0x611D, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x61DA..<0x61DE, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x62F0..<0x62F6, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6757..<0x675B, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x68D7..<0x68E1, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6C81..<0x6C85, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6D17..<0x6D1F, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x6F7A..<0x6F80, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7069..<0x706F, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x726A..<0x7270, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7383..<0x7389, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x74C5..<0x74C9, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7574..<0x757A, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7621..<0x7629, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x773F..<0x7747, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7AC8..<0x7ACC, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7C7F..<0x7C8B, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7DBF..<0x7DC9, in: 0x06, selectedBank: 0x06)
disassembleJumpTable(within: 0x7EC7..<0x7ECB, in: 0x06, selectedBank: 0x06)

// TODO:

disassembleJumpTable(within: 0x40B5..<0x40B7, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x42CD..<0x42CF, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4545..<0x4547, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4715..<0x4717, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x489D..<0x489F, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x49FE..<0x4A00, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4AB3..<0x4AB5, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4B8E..<0x4B90, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4CDF..<0x4CE1, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x4F1A..<0x4F1C, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5124..<0x5126, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5627..<0x5629, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x59B4..<0x59B6, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5B95..<0x5B97, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5E3C..<0x5E3E, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x6221..<0x6223, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x640F..<0x6411, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x64BC..<0x64BE, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x654C..<0x654E, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x66A4..<0x66A6, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x6862..<0x6864, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x69CF..<0x69D1, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x71EB..<0x71ED, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x731A..<0x731C, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x747F..<0x7481, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x7547..<0x7549, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x772F..<0x7731, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x788F..<0x7891, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x7D88..<0x7D8A, in: 0x07, selectedBank: 0x07)
disassembleJumpTable(within: 0x5001..<0x5003, in: 0x14, selectedBank: 0x14)
disassembleJumpTable(within: 0x40A7..<0x40A9, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x410C..<0x410E, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x41D6..<0x41D8, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x4249..<0x424B, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x42BC..<0x42BE, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x44E8..<0x44EA, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x45F1..<0x45F3, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x4728..<0x472A, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x4F6B..<0x4F6D, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x50BB..<0x50BD, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x7701..<0x7703, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x78E1..<0x78E3, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x7C41..<0x7C43, in: 0x15, selectedBank: 0x15)
disassembleJumpTable(within: 0x488B..<0x488D, in: 0x17, selectedBank: 0x17)
disassembleJumpTable(within: 0x754D..<0x754F, in: 0x17, selectedBank: 0x17)
disassembleJumpTable(within: 0x401F..<0x4021, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4390..<0x4392, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4547..<0x4549, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4962..<0x4964, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4A04..<0x4A06, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4BA1..<0x4BA3, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4BFC..<0x4BFE, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4CF7..<0x4CF9, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4DE8..<0x4DEA, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x4E56..<0x4E58, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x52CC..<0x52CE, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x552B..<0x552D, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x58AB..<0x58AD, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x5B93..<0x5B95, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x5E21..<0x5E23, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x5F02..<0x5F04, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x60E9..<0x60EB, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x61A3..<0x61A5, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x63F2..<0x63F4, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x65B3..<0x65B5, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x6A65..<0x6A67, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x6F70..<0x6F72, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x6FFD..<0x6FFF, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x7175..<0x7177, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x735D..<0x735F, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x773D..<0x773F, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x7828..<0x782A, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x7E82..<0x7E84, in: 0x18, selectedBank: 0x18)
disassembleJumpTable(within: 0x406A..<0x406C, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x428F..<0x4291, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4495..<0x4497, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x461C..<0x461E, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4942..<0x4944, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4A33..<0x4A35, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4CB3..<0x4CB5, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x4D7B..<0x4D7D, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x51A9..<0x51AB, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5350..<0x5352, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x54DD..<0x54DF, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5609..<0x560B, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5719..<0x571B, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5823..<0x5825, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5B29..<0x5B2B, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5CB6..<0x5CB8, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5E07..<0x5E09, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x5F1E..<0x5F20, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x614A..<0x614C, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x65E2..<0x65E4, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x682E..<0x6830, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x68B7..<0x68B9, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x69CC..<0x69CE, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x6BF5..<0x6BF7, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x6E51..<0x6E53, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x70CD..<0x70CF, in: 0x19, selectedBank: 0x19)
disassembleJumpTable(within: 0x76A8..<0x76AA, in: 0x19, selectedBank: 0x19)

// MARK: - Entity table.

var entityJumpTableBanks: [UInt8: LR35902.Bank] = [:]
var jumpTableFunctions: [UInt8: String] = [:]
for (value, name) in disassembly.valuesForDatatype(named: "ENTITY")! {
  let address = 0x4000 + LR35902.Address(value)
  disassembly.setLabel(at: address, in: 0x03, named: "\(name)_bank")
  disassembly.setData(at: address, in: 0x03)

  let entityBankLocation = LR35902.cartAddress(for: address, in: 0x03)!
  let bank = data[Int(entityBankLocation)]
  entityJumpTableBanks[value] = bank
  jumpTableFunctions[value] = "JumpTable_\(name)"
}

disassembly.register(bankChange: 0x03, at: 0x3945, in: 0x00)
disassembly.register(bankChange: 0x00, at: 0x3951, in: 0x00)
disassembleJumpTable(within: 0x3953..<(0x3953 + 0xFF * 2), in: 0x00, bankTable: entityJumpTableBanks, functionNames: jumpTableFunctions)

disassembly.disassembleAsGameboyCartridge()

// MARK: - Bank 0 (00)

disassembly.defineFunction(startingAt: 0x0150, in: 0x00, named: "Main")
disassembly.setPreComment(at: 0x0156, in: 0x00, text: "Reset the palette registers to zero.")
disassembly.setPreComment(at: 0x015D, in: 0x00, text: "Clears 6144 bytes of video ram. Graphics vram location for OBJ and BG tiles start at $8000 and end at $97FF; for a total of 0x1800 bytes.")
disassembly.setLabel(at: 0x01a6, in: 0x00, named: "frameDidRender")
disassembly.setPreComment(at: 0x01b7, in: 0x00, text: "Load a with a value that is non-zero every other frame.")
disassembly.setLabel(at: 0x01aa, in: 0x00, named: "renderLoop_setScrollY")
disassembly.setLabel(at: 0x01be, in: 0x00, named: "defaultShakeBehavior")
disassembly.setLabel(at: 0x01c4, in: 0x00, named: "setScrollY")
disassembly.setLabel(at: 0x01f5, in: 0x00, named: "playAudio")
disassembly.setLabel(at: 0x01fb, in: 0x00, named: "skipAudio")
disassembly.setPreComment(at: 0x2872, in: 0x00, text: """
hl = address after rst $00 invocation
hl += [0, a << 1]
hl = [ram[hl + 1], ram[hl]]
jp hl
""")
disassembly.defineFunction(startingAt: 0x2872, in: 0x00, named: "JumpTable")
disassembly.setLabel(at: 0x03bd, in: 0x00, named: "waitForNextFrame")
disassembly.setLabel(at: 0x038a, in: 0x00, named: "engineIsPaused")
disassembly.setLabel(at: 0x03a4, in: 0x00, named: "checkEnginePaused")
disassembly.defineFunction(startingAt: 0x04a1, in: 0x00, named: "LoadMapData")
disassembly.setLabel(at: 0x04f5, in: 0x00, named: "loadMapZero")
disassembly.setLabel(at: 0x0516, in: 0x00, named: "cleanupAndReturn")
disassembly.defineFunction(startingAt: 0x07B9, in: 0x00, named: "SetBank")
disassembly.defineFunction(startingAt: 0x0844, in: 0x00, named: "PlayAudioStep")
disassembly.defineFunction(startingAt: 0x27fe, in: 0x00, named: "ReadJoypadState")
disassembly.setType(at: 0x2827, in: 0x00, to: "binary")
disassembly.setPreComment(at: 0x282A, in: 0x00, text: "Store the read joypad state into c")
disassembly.defineFunction(startingAt: 0x2881, in: 0x00, named: "LCDOff")
disassembly.defineFunction(startingAt: 0x28A8, in: 0x00, named: "FillBGWith7F")
disassembly.defineFunction(startingAt: 0x28C5, in: 0x00, named: "CopyMemoryRegion")
disassembly.defineFunction(startingAt: 0x28F2, in: 0x00, named: "CopyBackgroundData")
disassembly.defineFunction(startingAt: 0x298A, in: 0x00, named: "ClearHRAM")
disassembly.defineFunction(startingAt: 0x2999, in: 0x00, named: "ClearMemoryRegion")
disassembly.defineFunction(startingAt: 0x2B6B, in: 0x00, named: "LoadInitialTiles")

// MARK: - Bank 1 (01)
disassembly.defineFunction(startingAt: 0x40CE, in: 0x01, named: "LCDOn")
disassembly.defineFunction(startingAt: 0x46DD, in: 0x01, named: "InitSave")
disassembly.defineFunction(startingAt: 0x460F, in: 0x01, named: "InitSaves")
disassembly.defineFunction(startingAt: 0x7D19, in: 0x01, named: "CopyDMATransferToHRAM")
disassembly.defineFunction(startingAt: 0x7D27, in: 0x01, named: "DMATransfer")

// MARK: - Bank 5 (05)
disassembly.setData(at: 0x5919..<(0x5919 + 0x0010), in: 0x05)
disassembly.setData(at: 0x5939..<(0x5939 + 0x0010), in: 0x05)

// MARK: - Bank 9 (09)
extractText(from: LR35902.cartAddress(for: 0x6700, in: 0x09)!..<LR35902.cartAddress(for: 0x6d9f, in: 0x09)!)
extractText(from: LR35902.cartAddress(for: 0x7d00, in: 0x09)!..<LR35902.cartAddress(for: 0x7eef, in: 0x09)!)

// MARK: - Bank 12 (0c)
disassembly.setData(at: 0x4000..<(0x4000 + 0x0400), in: 0x0c)
disassembly.setData(at: 0x4800..<(0x4800 + 0x1000), in: 0x0c)
disassembly.setData(at: 0x47a0..<(0x47a0 + 0x0020), in: 0x0c)

// MARK: - Bank 20 (14)
extractText(from: LR35902.cartAddress(for: 0x5c00, in: 0x14)!..<LR35902.cartAddress(for: 0x79cd, in: 0x14)!)

// MARK: - Bank 22 (16)
extractText(from: LR35902.cartAddress(for: 0x5700, in: 0x16)!..<LR35902.cartAddress(for: 0x7ff0, in: 0x16)!)

// MARK: - Bank 23 (17)
disassembly.setLabel(at: 0x4099, in: 0x17, named: "CreditsText")
disassembly.setText(at: 0x4099..<0x42fd, in: 0x17)

// MARK: - Bank 27 (1b)
disassembly.defineFunction(startingAt: 0x4006, in: 0x1b, named: "AudioStep1b_Launcher")
disassembly.defineFunction(startingAt: 0x401e, in: 0x1b, named: "AudioStep1b_Start")
disassembly.defineFunction(startingAt: 0x4037, in: 0x1b, named: "CheckAudioSelection")
disassembly.defineFunction(startingAt: 0x42ae, in: 0x1b, named: "CheckAndResetAudio_Variant1")
disassembly.defineFunction(startingAt: 0x40ef, in: 0x1b, named: "CheckAndResetAudio_Variant2")
//disassembly.defineFunction(startingAt: 0x4275, in: 0x1b, named: "SelectAudioTerminals")
//disassembly.defineFunction(startingAt: 0x4392, in: 0x1b, named: "LoadHLIndirectToB")

disassembly.setLabel(at: 0x415d, in: 0x1b, named: "AudioData")
for i in LR35902.Address(0)..<LR35902.Address(32) {
  // TODO: Allow data to be grouped.
  disassembly.setData(at: (0x415d + i * 6)..<(0x415d + (i + 1) * 6), in: 0x1b)
}

// MARK: - Bank 28 (1c)
extractText(from: LR35902.cartAddress(for: 0x4a00, in: 0x1c)!..<LR35902.cartAddress(for: 0x7360, in: 0x1c)!)

// MARK: - Bank 28 (1d)
extractText(from: LR35902.cartAddress(for: 0x4000, in: 0x1d)!..<LR35902.cartAddress(for: 0x7FB6, in: 0x1d)!)

// MARK: - Bank 31 (1f)
disassembly.defineFunction(startingAt: 0x4000, in: 0x1f, named: "EnableSound")
disassembly.defineFunction(startingAt: 0x4006, in: 0x1f, named: "PlayAudioStep_Launcher")
disassembly.setLabel(at: 0x401e, in: 0x1f, named: "PlayAudioStep_Start")

disassembly.defineFunction(startingAt: 0x4204, in: 0x1f, named: "InitSquareSound")
disassembly.setLabel(at: 0x53e6, in: 0x1f, named: "ClearActiveSquareSound")

disassembly.defineFunction(startingAt: 0x53ed, in: 0x1f, named: "InitWaveSound")
disassembly.setLabel(at: 0x6385, in: 0x1f, named: "ClearActiveWaveSound")

disassembly.defineFunction(startingAt: 0x64e8, in: 0x1f, named: "InitNoiseSound")
disassembly.setLabel(at: 0x650e, in: 0x1f, named: "_InitNoiseSoundNoNoiseSound")
disassembly.setLabel(at: 0x7a28, in: 0x1f, named: "ClearActiveNoiseSound")

disassembly.setLabel(at: 0x7a60, in: 0x1f, named: "_ShiftHL")

disassembly.defineFunction(startingAt: 0x7f80, in: 0x1f, named: "SoundUnknown1")

disassembly.defineMacro(named: "jumpTable", instructions: [
  .instruction(.init(spec: .rst(.x00))),
]) /*{ args, address, bank in
  print("disassembleJumpTable(within: 0x\((address + 1).hexString)..<0x\((address + 3).hexString), in: 0x\(bank.hexString), selectedBank: 0x\(bank.hexString))")
}*/


disassembly.defineMacro(named: "changebank", instructions: [
  .any(.ld(.a, .imm8)),
  .instruction(.init(spec: .ld(.imm16addr, .a), imm16: 0x2100)),
], code: [
  .ld(.a, .arg(1)),
  .ld(.imm16addr, .a),
])

disassembly.defineMacro(named: "_changebank", instructions: [
  .any(.ld(.a, .imm8)),
  .instruction(.init(spec: .call(nil, .imm16), imm16: 0x07b9))
], code: [
  .ld(.a, .arg(1)),
  .call(nil, .imm16),
])

disassembly.defineMacro(named: "__changebank", instructions: [
  .instruction(.init(spec: .ld(.hl, .imm16), imm16: 0x2100)),
  .any(.ld(.hladdr, .imm8)),
], code: [
  .ld(.hl, .imm16),
  .ld(.hladdr, .arg(1))
])

// TODO: Add validation for a label existing for a given argument.
//disassembly.defineMacro(named: "_callcb", instructions: [
//  .any(.ld(.a, .imm8)),
//  .instruction(.init(spec: .call(nil, .imm16), imm16: 0x07b9)),
//  .any(.call(nil, .imm16))
//], code: [
//  .ld(.a, .macro("bank(\\1)")),
//  .call(nil, .imm16),
//  .call(nil, .arg(1))
//], validArgumentValues: [
//  1: IndexSet(integersIn: 0x4000..<0x8000)
//])

disassembly.defineMacro(named: "callcb", instructions: [
  .any(.ld(.a, .imm8)),
  .instruction(.init(spec: .ld(.imm16addr, .a), imm16: 0x2100)),
  .any(.call(nil, .imm16))
], code: [
  .ld(.a, .macro("bank(\\1)")),
  .ld(.imm16addr, .a),
  .call(nil, .arg(1))
], validArgumentValues: [
  1: IndexSet(integersIn: 0x4000..<0x8000)
])

disassembly.defineMacro(named: "copyRegion", instructions: [
  .any(.ld(.hl, .imm16)),
  .any(.ld(.de, .imm16)),
  .any(.ld(.bc, .imm16)),
  .instruction(.init(spec: .call(nil, .imm16), imm16: 0x28C5)),
], code: [
  .ld(.hl, .arg(1)),
  .ld(.de, .arg(3)),
  .ld(.bc, .arg(2)),
  .call(nil, .imm16),
]) /*{ args, address, bank in
  print("disassembly.setData(at: \(args[1]!)..<(\(args[1]!) + \(args[2]!)), in: 0x\(bank.hexString))")
}*/

disassembly.defineMacro(named: "copyRegion_", instructions: [
  .any(.ld(.hl, .imm16)),
  .any(.ld(.de, .imm16)),
  .any(.ld(.bc, .imm16)),
  .instruction(.init(spec: .jp(nil, .imm16), imm16: 0x28C5)),
], code: [
  .ld(.hl, .arg(1)),
  .ld(.de, .arg(3)),
  .ld(.bc, .arg(2)),
  .jp(nil, .imm16),
]) /*{ args, address, bank in
  print("disassembly.setData(at: \(args[1]!)..<(\(args[1]!) + \(args[2]!)), in: 0x\(bank.hexString))")
}*/

disassembly.defineMacro(named: "copyRegion__", instructions: [
  .any(.ld(.de, .imm16)),
  .any(.ld(.hl, .imm16)),
  .any(.ld(.bc, .imm16)),
  .instruction(.init(spec: .jp(nil, .imm16), imm16: 0x28C5)),
], code: [
  .ld(.de, .arg(3)),
  .ld(.hl, .arg(1)),
  .ld(.bc, .arg(2)),
  .jp(nil, .imm16),
]) /*{ args, address, bank in
  print("disassembly.setData(at: \(args[1]!)..<(\(args[1]!) + \(args[2]!)), in: 0x\(bank.hexString))")
}*/

disassembly.defineMacro(named: "modifySave", instructions: [
  .any(.ld(.a, .imm8)),
  .any(.ld(.imm16addr, .a))
  ], code: [
    .ld(.a, .arg(2)),
    .ld(.arg(1), .a)
  ], validArgumentValues: [
    1: IndexSet(integersIn: 0xA100..<0xAB8F)
])

disassembly.defineMacro(named: "ifAnyPressed", instructions: [
  .instruction(.init(spec: .ld(.a, .ffimm8addr), imm8: 0xcb)),
  .any(.and(.imm8)),
  .any(.jr(.nz, .simm8)),
], code: [
  .ld(.a, .ffimm8addr),
  .and(.arg(1)),
  .jr(.nz, .arg(2)),
])

disassembly.defineMacro(named: "ifNotPressed", instructions: [
  .instruction(.init(spec: .ld(.a, .ffimm8addr), imm8: 0xcb)),
  .any(.and(.imm8)),
  .any(.jr(.z, .simm8)),
], code: [
  .ld(.a, .ffimm8addr),
  .and(.arg(1)),
  .jr(.z, .arg(2)),
])

disassembly.defineMacro(named: "resetAudio", template: """
xor  a
ld   [$D361], a
ld   [$D371], a
ld   [$D31F], a

ld   [$D32F], a
ld   [$D33F], a

ld   [$D39E], a
ld   [$D39F], a

ld   [$D3D9], a
ld   [$D3DA], a

ld   [$D3B6], a
ld   [$D3B7], a
ld   [$D3B8], a
ld   [$D3B9], a
ld   [$D3BA], a
ld   [$D3BB], a

ld   [$D394], a
ld   [$D395], a
ld   [$D396], a

ld   [$D390], a
ld   [$D391], a
ld   [$D392], a

ld   [$D3C6], a
ld   [$D3C7], a
ld   [$D3C8], a

ld   [$D3A0], a
ld   [$D3A1], a
ld   [$D3A2], a

ld   [$D3CD], a

ld   [$D3D6], a
ld   [$D3D7], a
ld   [$D3D8], a

ld   [$D3DC], a

ld   [$D3E7], a

ld   [$D3E2], a
ld   [$D3E3], a
ld   [$D3E4], a

ld   a, %00001000
ld   [$FF12], a
ld   [$FF17], a

ld   a, %10000000
ld   [$FF14], a
ld   [$FF19], a

xor  a
ld   [$FF10], a

ld   [$ff1a], a
""")

try disassembly.writeTo(directory: "/Users/featherless/workbench/gbdis/disassembly")

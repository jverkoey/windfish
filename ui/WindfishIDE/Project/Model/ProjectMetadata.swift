import Foundation
import Windfish

struct ProjectMetadata: Codable {
  var romUrl: URL
  var numberOfBanks: Gameboy.Cartridge.Bank
  var bankMap: [String: Gameboy.Cartridge.Bank]
}

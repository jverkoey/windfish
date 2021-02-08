import Foundation

import Tracing
import Windfish

struct ProjectMetadata: Codable {
  var romUrl: URL
  var numberOfBanks: Cartridge.Bank
  var bankMap: [String: Cartridge.Bank]
}

import Foundation

class ProjectConfiguration: NSObject, Codable {
  @objc dynamic var regions: [Region] = []
  @objc dynamic var dataTypes: [DataType] = []
  @objc dynamic var globals: [Global] = []
  @objc dynamic var macros: [Macro] = []
  @objc dynamic var scripts: [Script] = []

  override init() {
    super.init()
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Self.CodingKeys)
    regions = (try? container.decode(Array<Region>.self, forKey: .regions)) ?? []
    dataTypes = (try? container.decode(Array<DataType>.self, forKey: .dataTypes)) ?? []
    globals = (try? container.decode(Array<Global>.self, forKey: .globals)) ?? []
    macros = (try? container.decode(Array<Macro>.self, forKey: .macros)) ?? []
    scripts = (try? container.decode(Array<Script>.self, forKey: .scripts)) ?? []
  }
}

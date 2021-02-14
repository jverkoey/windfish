import Foundation

import Windfish

class ProjectConfiguration: NSObject {
  @objc dynamic var regions: [Region] = [] {
    didSet { storage.regions = regions.map { $0.storage } }
  }
  @objc dynamic var dataTypes: [DataType] = [] {
    didSet { storage.dataTypes = dataTypes.map { $0.storage } }
  }
  @objc dynamic var globals: [Global] = [] {
    didSet { storage.globals = globals.map { $0.storage } }
  }
  @objc dynamic var macros: [Macro] = [] {
    didSet { storage.macros = macros.map { $0.storage } }
  }
  @objc dynamic var scripts: [Script] = [] {
    didSet { storage.scripts = scripts.map { $0.storage } }
  }

  var storage: Windfish.Project = Windfish.Project()
}

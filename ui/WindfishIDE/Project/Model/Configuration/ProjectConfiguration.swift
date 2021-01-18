import Foundation

class ProjectConfiguration: NSObject {
  @objc dynamic var regions: [Region] = []
  @objc dynamic var dataTypes: [DataType] = []
  @objc dynamic var globals: [Global] = []
  @objc dynamic var macros: [Macro] = []
  @objc dynamic var scripts: [Script] = []

  override init() {
    super.init()
  }
}

import Foundation

import Windfish

final class DataType: NSObject {
  typealias Storage = Windfish.Project.DataType

  init(storage: Storage) {
    self.storage = storage
    self.mappings = storage.mappings.map { Mapping(storage: $0) }
  }

  init(name: String, representation: String, interpretation: String, mappings: [Mapping]) {
    self.storage = Storage(name: name, representation: representation, interpretation: interpretation, mappings: mappings.map {
      return $0.storage
    })
    self.mappings = mappings
  }

  final class Mapping: NSObject, Codable {
    init(storage: Storage.Mapping) {
      self.storage = storage
    }

    init(name: String, value: UInt8) {
      self.storage = Storage.Mapping(name: name, value: value)
    }

    @objc dynamic var name: String {
      get { return storage.name }
      set { storage.name = newValue }
    }
    @objc dynamic var value: UInt8 {
      get { return storage.value }
      set { storage.value = newValue }
    }

    // Internal storage.
    fileprivate let storage: Storage.Mapping
  }

  @objc dynamic var name: String {
    get { return storage.name }
    set { storage.name = newValue }
  }
  @objc dynamic var representation: String {
    get { return storage.representation }
    set { storage.representation = newValue }
  }
  @objc dynamic var interpretation: String {
    get { return storage.interpretation }
    set { storage.interpretation = newValue }
  }
  @objc dynamic var mappings: [Mapping] {
    didSet { storage.mappings = mappings.map { $0.storage } }
  }

  // Internal storage.
  let storage: Storage
}

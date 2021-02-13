import Foundation

extension Project {
  final class Macro: NSObject {
    init(name: String, source: String) {
      self.name = name
      self.source = source
    }

    var name: String
    var source: String
  }

  static func loadMacros(from url: URL) -> [Macro] {
    let fm = FileManager.default
    return ((try? fm.contentsOfDirectory(atPath: url.path)) ?? [])
      .compactMap { (filename: String) -> Macro? in
        guard let data: Data = fm.contents(atPath: url.appendingPathComponent(filename).path) else {
          return nil
        }
        return Macro(name: URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent,
                     source: String(data: data, encoding: .utf8)!)
      }
  }
}

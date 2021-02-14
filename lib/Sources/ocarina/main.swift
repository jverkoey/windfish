import Foundation

import ArgumentParser
import Windfish

struct Ocarina: ParsableCommand {
  @Option(help: "The path to the windish project directory.")
  var projectDirectory: String

  func run() throws {
    let project = try Project.load(from: URL(fileURLWithPath: projectDirectory))
    print(project)
  }
}

Ocarina.main()

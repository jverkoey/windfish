import Foundation

import ArgumentParser
import Windfish

struct Ocarina: ParsableCommand {
  @Option(help: "The path to the windish project directory.")
  var projectDirectory: String

  mutating func run() throws {
    print(projectDirectory)
  }
}

Ocarina.main()

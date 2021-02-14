import Foundation

import ArgumentParser
import Windfish

struct Ocarina: ParsableCommand {
  enum Command: String, Decodable, CaseIterable {
    case createProject = "create"
    case disassembleProject = "disassemble"
  }

  @Argument(help: "Select one of \(Command.allCases.map { $0.rawValue }.joined(separator: ", "))")
  var commands: [String] = []

  @Option(help: "The path to the Windish project directory.")
  var projectDirectory: String

  var command: Command?

  mutating func validate() throws {
    guard let commandArgument: String = commands.first else {
      throw ValidationError("Please specify a command.")
    }
    guard let command = Command(rawValue: commandArgument) else {
      throw ValidationError("\(commandArgument) is not a recognized command.")
    }
    self.command = command
  }

  func run() throws {
    guard let command = command else {
      throw ValidationError("Please specify a command.")
    }
    switch command {
    case .createProject:
      print("Creating new project...")

    case .disassembleProject:
      let project = try Project.load(from: URL(fileURLWithPath: projectDirectory))
      print(project)
    }
  }
}

Ocarina.main()

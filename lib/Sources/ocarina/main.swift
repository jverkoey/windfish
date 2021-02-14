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

  @Option(help: "The path to the rom that Windfish should disassemble. Required only when using \(Command.createProject.rawValue)")
  var romPath: String?

  @Option(help: "The path to the Windish project directory.")
  var projectDirectory: String

  var command: Command?
  var romData: Data?

  mutating func validate() throws {
    guard let commandArgument: String = commands.first else {
      throw ValidationError("Please specify a command.")
    }
    guard let command = Command(rawValue: commandArgument) else {
      throw ValidationError("\(commandArgument) is not a recognized command.")
    }
    switch command {
    case .createProject:
      guard let romPath = romPath else {
        throw ValidationError("No rom path provided.")
      }
      guard FileManager.default.fileExists(atPath: romPath) else {
        throw ValidationError("No rom found at \(romPath).")
      }
      self.romData = try Data(contentsOf: URL(fileURLWithPath: romPath))

    case .disassembleProject:
      break // No extra validation required.
    }
    self.command = command
  }

  func run() throws {
    guard let command = command else {
      throw ValidationError("Please specify a command.")
    }
    let projectUrl: URL = URL(fileURLWithPath: projectDirectory)
    switch command {
    case .createProject:
      guard let romData = romData else {
        throw ValidationError("No rom data found.")
      }
      print("Creating new project...")
      let project = Project(rom: romData)
      try project.save(to: projectUrl)
      print("Created.")

    case .disassembleProject:
      let project = try Project.load(from: projectUrl)
      print(project)
    }
  }
}

Ocarina.main()

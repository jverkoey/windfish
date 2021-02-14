import Foundation

import ArgumentParser
import Tracing
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
  lazy var projectUrl: URL = { URL(fileURLWithPath: projectDirectory) }()

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
      guard romPath == nil else {
        throw ValidationError("Do not provide a rom path when disassembling; the rom is loaded from the project.")
      }
    }
    self.command = command
  }

  mutating func run() throws {
    guard let command = command else {
      throw ValidationError("Please specify a command.")
    }
    switch command {
    case .createProject:      try createProject()
    case .disassembleProject: try disassembleProject()
    }
  }

  mutating func createProject() throws {
    guard let romData = romData else {
      throw ValidationError("No rom data found.")
    }
    print("Creating new project...")
    let project = Project(rom: romData)
    try project.save(to: projectUrl)
    print("Created.")
  }

  mutating func disassembleProject() throws {
    let project = try Project.load(from: projectUrl)
    guard let romData: Data = project.rom else {
      throw ValidationError("""
No rom data found in the project.

If the project already has a disassembly directory, then you can create the ROM by running the following commands:

cd \(projectDirectory)/\(Project.Filenames.disassembly)
make
cp game.gb ../rom.gb
""")
    }
    let disassembly: Disassembler = Disassembler(data: romData)
    project.prepare(disassembly.mutableConfiguration)
    disassembly.willStart()
    project.apply(to: disassembly.mutableConfiguration)
    disassembly.disassemble()

    let (disassembledSource, statistics) = try! disassembly.generateSource()
    let disassemblyUrl: URL = projectUrl.appendingPathComponent(Project.Filenames.disassembly)
    try FileManager.default.createDirectory(at: disassemblyUrl, withIntermediateDirectories: true, attributes: nil)

    try disassembledSource.sources.forEach { (filename: String, fileDescription: Disassembler.Source.FileDescription) in
      try fileDescription.asData()?.write(to: disassemblyUrl.appendingPathComponent(filename))
    }

    print("""
Disassembly statistics:
- Instructions decoded: \(statistics.instructionsDecoded)
- Percent of ROM decoded: \(String(format: "%.2f", statistics.percent))%
Percent decoded of each bank:
\(statistics.bankPercents.sorted { $0.key < $1.key }.map({ (key: Cartridge.Bank, value: Double) -> String in
  "\(key.hexString): \(String(format: "%.2f", value))%"
}).joined(separator: "\n"))
""")
    print(statistics)
  }
}

Ocarina.main()

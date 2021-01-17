import AppKit
import Foundation
import Cocoa

import Windfish

extension ProjectDocument {
  enum SymbolSection {
    case unknown
    case labels
    case definitions
  }
  func importSymbolsContents(_ symbols: String) {
    var section: SymbolSection = .unknown
    symbols.enumerateLines { (line, _) in
      if line.hasPrefix("[") {
        let sectionName = line.components(separatedBy: CharacterSet(charactersIn: "[]"))[1]
        switch sectionName {
        case "labels": section = .labels
        case "definitions": section = .definitions
        default:
          section = .unknown
          preconditionFailure("Unknown section: \(sectionName)")
        }
        return
      }
      if section == .unknown {
        return
      }
      if line.isEmpty {
        return
      }
      let parts = line.split(separator: " ")
      switch section {
      case .labels:
        let locationParts = parts[0].split(separator: ":")
        let labelName = parts[1]
        let bank = Gameboy.Cartridge.Bank(locationParts[0], radix: 16)!
        let address = LR35902.Address(locationParts[1], radix: 16)!

        if Gameboy.Cartridge.location(for: address, inHumanProvided: bank) != nil {
          self.project.configuration.regions.removeAll {
            $0.bank == bank && $0.address == address
          }
          self.project.configuration.regions.append(Region(
            regionType: Region.Kind.label,
            name: String(labelName),
            bank: bank,
            address: address,
            length: 0
          ))
        }

      case .definitions:
        break

      default: fatalError()
      }
    }
  }

  @IBAction @objc func importSymbols(_ sender: Any?) {
    let openPanel = NSOpenPanel()
    openPanel.allowedFileTypes = ["sym"]
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    if let window = contentViewController?.view.window {
      openPanel.beginSheetModal(for: window) { response in
        if response == .OK, let url = openPanel.url {
          let symbols = try! String(contentsOf: url)
          self.importSymbolsContents(symbols)
          self.disassemble(nil)
        }
      }
    }
  }
}

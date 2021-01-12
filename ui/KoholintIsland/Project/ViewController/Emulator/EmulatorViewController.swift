import Foundation
import Combine
import Cocoa

import Windfish

extension NSUserInterfaceItemIdentifier {
  static let programCounter = NSUserInterfaceItemIdentifier("pc")
  static let register = NSUserInterfaceItemIdentifier("name")
  static let variableName = NSUserInterfaceItemIdentifier("variableName")
  static let registerValue = NSUserInterfaceItemIdentifier("value")
  static let registerSourceLocation = NSUserInterfaceItemIdentifier("sourceLocation")
  static let registerVariableAddress = NSUserInterfaceItemIdentifier("variableAddress")
}

private enum NumericalRepresentation {
  case hex
  case decimal
}

extension Disassembler.SourceLocation {
  func address() -> LR35902.Address {
    switch self {
    case .cartridge(let location):
      return Gameboy.Cartridge.addressAndBank(from: location).address
    case .memory(let address):
      return address
    }
  }
}

extension String {
  /** Returns a numerical representation of the string and its detected representation format. */
  fileprivate func numberRepresentation<T: FixedWidthInteger>(_ type: T.Type) -> (NumericalRepresentation, T)? {
    if isEmpty {
      return nil
    }

    if hasPrefix("0x") {
      guard let value = T(dropFirst(2), radix: 16) else {
        return nil
      }
      return (.hex, value)
    }

    guard let value = T(self) else {
      return nil
    }
    return (.decimal, value)
  }

  /** Returns a numerical representation of the hexadecimal string. */
  fileprivate func hexRepresentation<T: FixedWidthInteger>(_ type: T.Type) -> T? {
    if isEmpty {
      return nil
    }

    if hasPrefix("0x") {
      return T(dropFirst(2), radix: 16)
    }

    return T(self, radix: 16)
  }

  /** Returns a numerical representation of the hexadecimal string. */
  fileprivate func addressAndBankRepresentation() -> Gameboy.Cartridge.Location? {
    if isEmpty {
      return nil
    }

    let parts = self.split(separator: ".", maxSplits: 1)
    guard let bank = Gameboy.Cartridge.Bank(parts[0], radix: 16),
          let address = LR35902.Address(parts[1].dropFirst(2), radix: 16) else {
      return nil
    }
    return Gameboy.Cartridge.location(for: address, in: bank)
  }
}

extension NSImage {
  /// Create a CGImage using the best representation of the image available in the NSImage for the image size
  ///
  /// - Returns: Converted image, or nil
  func asCGImage() -> CGImage? {
    var rect = NSRect(origin: CGPoint(x: 0, y: 0), size: self.size)
    return self.cgImage(forProposedRect: &rect, context: NSGraphicsContext.current, hints: nil)
  }
}

extension FixedWidthInteger {
  /** Returns a string representation of the integer in the given representation format. */
  fileprivate func stringWithRepresentation(_ representation: NumericalRepresentation) -> String {
    switch representation {
    case .hex:
      return "0x" + self.hexString
    case .decimal:
    return "\(self)"
    }
  }
}

extension Disassembler.SourceLocation {
  /** Returns a string representation of the integer in the given representation format. */
  fileprivate func stringWithAddressAndBank() -> String {
    switch self {
    case .cartridge(let location):
      let (address, bank) = Gameboy.Cartridge.addressAndBank(from: location)
      return  bank.hexString + "." + address.stringWithRepresentation(.hex)
    case .memory(let address):
      return  address.hexString
    }
  }
}

private final class CPURegister: NSObject {
  init(name: String, register: LR35902.Instruction.Numeric, value: String?, sourceLocation: String?, variableAddress: LR35902.Address, variableName: String? = nil) {
    self.name = name
    self.register = register
    self.value = value
    self.sourceLocation = sourceLocation
    self.variableAddress = variableAddress
    self.variableName = variableName
  }

  @objc dynamic var name: String
  var register: LR35902.Instruction.Numeric
  @objc dynamic var value: String?
  var valueRepresentation: NumericalRepresentation = .hex
  @objc dynamic var sourceLocation: String?
  @objc dynamic var variableAddress: LR35902.Address
  @objc dynamic var variableName: String?
}

private final class RAMValue: NSObject {
  init(address: LR35902.Address, variableName: String?, value: String, sourceLocation: String?, variableAddress: LR35902.Address) {
    self.address = address
    self.variableName = variableName
    self.value = value
    self.sourceLocation = sourceLocation
    self.variableAddress = variableAddress
  }

  @objc dynamic var address: LR35902.Address
  @objc dynamic var variableName: String?
  @objc dynamic var value: String
  @objc dynamic var sourceLocation: String?
  @objc dynamic var variableAddress: LR35902.Address
}

protocol EmulatorViewControllerDelegate: NSObject {
  func emulatorViewControllerDidStepIn(_ emulatorViewController: EmulatorViewController)
}

final class EmulatorViewController: NSViewController, TabSelectable, EmulationObservers {
  let deselectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!

  weak var delegate: EmulatorViewControllerDelegate?

  let document: ProjectDocument
  let registerStateController = NSArrayController()
  let instructionAssemblyLabel = CreateLabel()
  let instructionBytesLabel = CreateLabel()
  let tileDataImageView = PixelImageView()
  let fpsLabel = CreateLabel()
  let breakpointEditor = NSPredicateEditor()
  private let cpuView = LR35902RegistersView()

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  private var disassembledSubscriber: AnyCancellable?

  override func viewWillAppear() {
    super.viewWillAppear()

    document.emulationObservers.append(self)
  }

  override func loadView() {
    view = NSView()

    // MARK: Views

    let monospacedFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)

    let controls = NSSegmentedControl()
    controls.translatesAutoresizingMaskIntoConstraints = false
    controls.trackingMode = .momentary
    controls.segmentStyle = .smallSquare
    controls.segmentCount = 5
    controls.setImage(NSImage(systemSymbolName: "arrowshape.bounce.forward.fill", accessibilityDescription: nil)!, forSegment: 0)
    controls.setImage(NSImage(systemSymbolName: "arrow.down.to.line.alt", accessibilityDescription: nil)!, forSegment: 1)
    controls.setImage(NSImage(systemSymbolName: "arrow.right.to.line.alt", accessibilityDescription: nil)!, forSegment: 2)
    controls.setImage(NSImage(systemSymbolName: "play", accessibilityDescription: nil)!, forSegment: 3)
    controls.setImage(NSImage(systemSymbolName: "clear", accessibilityDescription: nil)!, forSegment: 4)
    controls.setWidth(40, forSegment: 0)
    controls.setWidth(40, forSegment: 1)
    controls.setWidth(40, forSegment: 2)
    controls.setWidth(40, forSegment: 3)
    controls.setWidth(40, forSegment: 4)
    controls.setEnabled(true, forSegment: 0)
    controls.setEnabled(true, forSegment: 1)
    controls.setEnabled(true, forSegment: 2)
    controls.setEnabled(true, forSegment: 3)
    controls.setEnabled(true, forSegment: 4)
    controls.target = self
    controls.action = #selector(performControlAction(_:))
    view.addSubview(controls)

    fpsLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(fpsLabel)

    cpuView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(cpuView)

    let instructionLabel = CreateLabel()
    instructionLabel.translatesAutoresizingMaskIntoConstraints = false
    instructionLabel.stringValue = "Instruction:"
    view.addSubview(instructionLabel)

    instructionAssemblyLabel.translatesAutoresizingMaskIntoConstraints = false
    instructionAssemblyLabel.stringValue = "Waiting for disassembly results..."
    instructionAssemblyLabel.font = monospacedFont
    instructionAssemblyLabel.maximumNumberOfLines = 5
    instructionAssemblyLabel.lineBreakStrategy = .standard
    view.addSubview(instructionAssemblyLabel)

    let instructionBytesLabelHeader = CreateLabel()
    instructionBytesLabelHeader.translatesAutoresizingMaskIntoConstraints = false
    instructionBytesLabelHeader.stringValue = "Instruction bytes:"
    view.addSubview(instructionBytesLabelHeader)

    instructionBytesLabel.translatesAutoresizingMaskIntoConstraints = false
    instructionBytesLabel.stringValue = "Waiting for disassembly results..."
    instructionBytesLabel.font = monospacedFont
    instructionBytesLabel.maximumNumberOfLines = 5
    instructionBytesLabel.lineBreakStrategy = .standard
    view.addSubview(instructionBytesLabel)

    tileDataImageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tileDataImageView)

    breakpointEditor.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(breakpointEditor)

    breakpointEditor.rowHeight = 25
    let operators = [
      NSNumber(value: NSComparisonPredicate.Operator.equalTo.rawValue)
    ]
    breakpointEditor.rowTemplates = [
      NSPredicateEditorRowTemplate(compoundTypes: [NSNumber(value: NSCompoundPredicate.LogicalType.or.rawValue),
                                                   NSNumber(value: NSCompoundPredicate.LogicalType.and.rawValue),
                                                   NSNumber(value: NSCompoundPredicate.LogicalType.not.rawValue)]),
      NSPredicateEditorRowTemplate(leftExpressions: [NSExpression(forKeyPath: "pc")],
                                   rightExpressionAttributeType: .integer16AttributeType,
                                   modifier: .direct,
                                   operators: operators,
                                   options: 0),
      NSPredicateEditorRowTemplate(leftExpressions: [NSExpression(forKeyPath: "bank")],
                                   rightExpressionAttributeType: .integer16AttributeType,
                                   modifier: .direct,
                                   operators: operators,
                                   options: 0),
    ]
    breakpointEditor.addRow(self)
    breakpointEditor.addRow(self)

    // MARK: Layout

    NSLayoutConstraint.activate([
      controls.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      controls.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      controls.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

      fpsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      fpsLabel.topAnchor.constraint(equalToSystemSpacingBelow: controls.bottomAnchor, multiplier: 1),

      cpuView.topAnchor.constraint(equalToSystemSpacingBelow: fpsLabel.bottomAnchor, multiplier: 1),
      cpuView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),

      instructionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
      instructionLabel.topAnchor.constraint(equalTo: cpuView.bottomAnchor),

      instructionAssemblyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionAssemblyLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
      instructionAssemblyLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor),

      instructionBytesLabelHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionBytesLabelHeader.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
      instructionBytesLabelHeader.topAnchor.constraint(equalTo: instructionAssemblyLabel.bottomAnchor),

      instructionBytesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionBytesLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
      instructionBytesLabel.topAnchor.constraint(equalTo: instructionBytesLabelHeader.bottomAnchor),

      tileDataImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      tileDataImageView.widthAnchor.constraint(equalToConstant: 128),
      tileDataImageView.heightAnchor.constraint(equalToConstant: 192),
      tileDataImageView.topAnchor.constraint(equalToSystemSpacingBelow: instructionBytesLabel.bottomAnchor, multiplier: 1),

      breakpointEditor.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      breakpointEditor.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      breakpointEditor.topAnchor.constraint(equalTo: tileDataImageView.bottomAnchor),
    ])

    tileDataImageView.image = document.gameboy.takeSnapshotOfTileData()

    updateInstructionAssembly()
    updateRegisters()

    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        self.updateInstructionAssembly()
      })

    breakpointEditor.action = #selector(didChangeBreakpoint(_:))
    breakpointEditor.target = self
  }

  @objc func didChangeBreakpoint(_ sender: NSPredicateEditor) {
    self.document.breakpointPredicate = sender.predicate
  }

  func emulationDidAdvance(screenImage: NSImage, tileDataImage: NSImage, fps: Double?, ips: Double?) {
    tileDataImageView.image = document.gameboy.takeSnapshotOfTileData()

    updateRegisters()

    if let fps = fps, let ips = ips {
      self.fpsLabel.stringValue = String(format: "fps: %.2f ips: %.2f", fps, ips)
    } else {
      self.fpsLabel.stringValue = "Not running"
    }
  }

  func emulationDidStart() {
    // Avoid flashing the instruction labels if the emulation concludes quickly enough.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      if self.document.emulating {
        self.instructionAssemblyLabel.stringValue = "Running..."
        self.instructionBytesLabel.stringValue = "Running..."
      }
    }
  }

  func emulationDidStop() {
//    self.writeImageHistory(to: "recording.gif")
    delegate?.emulatorViewControllerDidStepIn(self)
    self.updateInstructionAssembly()
  }

  @objc func performControlAction(_ sender: NSSegmentedControl) {
    if sender.selectedSegment == 0 {  // Step forward
      document.stepForward()

    } else if sender.selectedSegment == 1 {  // Step into
      document.stepInto()

    } else if sender.selectedSegment == 2 {  // Advance one machine cycle
      document.advance()

    } else if sender.selectedSegment == 3 {  // Play
      if document.emulating {
        document.stop()
      } else {
        document.run()
      }

    } else if sender.selectedSegment == 4 {  // Clear
      for register in LR35902.Instruction.Numeric.registers8 {
        document.gameboy.cpu.clear(register)
      }
      for register in LR35902.Instruction.Numeric.registers16 {
        document.gameboy.cpu.clear(register)
      }
      // TODO: Reset RAM.

      updateRegisters()
    }
  }
}

extension EmulatorViewController: NSTextFieldDelegate {
  func controlTextDidEndEditing(_ obj: Notification) {
    guard let textField = obj.object as? NSTextField,
          let identifier = textField.identifier else {
      preconditionFailure()
    }
    switch identifier {
    case .programCounter:
      document.gameboy.cpu.pc = textField.objectValue as! LR35902.Address
    default:
      preconditionFailure()
    }

    updateInstructionAssembly()
  }

  private func currentInstruction() -> LR35902.Instruction? {
    if var address = document.gameboy.cpu.machineInstruction.sourceLocation?.address() {
      return Disassembler.fetchInstruction(at: &address, memory: document.gameboy.memory)
    }

    if let spec = document.gameboy.cpu.machineInstruction.spec {
      if let operandWidth = LR35902.InstructionSet.widths[spec]?.operand,
         let sourceAddress = document.gameboy.cpu.machineInstruction.sourceAddress(),
         operandWidth > 0 {
        switch operandWidth {
        case 1:
          return LR35902.Instruction(spec: spec, immediate: .imm8(document.gameboy.memory.read(from: sourceAddress + 1)))
        case 2:
          let lsb = UInt16(truncatingIfNeeded: document.gameboy.memory.read(from: sourceAddress + 1))
          let msb = UInt16(truncatingIfNeeded: document.gameboy.memory.read(from: sourceAddress + 2)) << 8
          return LR35902.Instruction(spec: spec, immediate: .imm16(lsb | msb))
        default:
          break
        }
      }
      return LR35902.Instruction(spec: spec)
    }
    if let addressAndBank = document.gameboy.cpu.machineInstruction.sourceAddressAndBank() {
      // When a machine instruction has been loaded we need to look at it source location rather than the cpu's current
      // pc + bank as the CPU may have already incremented the pc as a result of reading the instruction's opcode.
      return document.disassemblyResults?.disassembly?.instruction(at: addressAndBank.address, in: max(1, addressAndBank.bank))
    }
    if let cartridge = document.gameboy.cartridge {
      return document.disassemblyResults?.disassembly?.instruction(at: document.gameboy.cpu.pc, in: max(1, cartridge.selectedBank))
    }
    return nil
  }

  private func updateInstructionAssembly() {
    guard let disassembly = document.disassemblyResults?.disassembly else {
      return
    }
    guard let instruction = currentInstruction() else {
      instructionAssemblyLabel.stringValue = "No instruction detected"
      instructionBytesLabel.stringValue = ""
      return
    }

    if let cartridge = document.gameboy.cartridge {
      let context = RGBDSDisassembler.Context(
        address: document.gameboy.cpu.pc,
        bank: max(1, cartridge.selectedBank),
        disassembly: disassembly,
        argumentString: nil
      )
      let statement = RGBDSDisassembler.statement(for: instruction, with: context)
      instructionAssemblyLabel.stringValue = statement.formattedString

      let bytes = LR35902.InstructionSet.opcodeBytes[instruction.spec]! + [UInt8](instruction.immediate?.asData() ?? Data())
      instructionBytesLabel.stringValue = bytes.map { "0x" + $0.hexString }.joined(separator: " ")
    }
  }

  func updateRegisters() {
    cpuView.update(with: document.gameboy.cpu)
  }
}

extension EmulatorViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let tableColumn = tableColumn else {
      preconditionFailure()
    }

    switch tableColumn.identifier {
    case .register, .name, .variableName:
      let identifier = NSUserInterfaceItemIdentifier.textCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
      }
      view.textField?.isEditable = false
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view

    case .registerValue:
      let identifier = NSUserInterfaceItemIdentifier.textCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
      }
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view

    case .registerSourceLocation, .registerVariableAddress:
      let identifier = NSUserInterfaceItemIdentifier.addressCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = LR35902AddressFormatter()
      }
      view.textField?.isEditable = false
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view

    case .address:
      let identifier = NSUserInterfaceItemIdentifier.addressCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = LR35902AddressFormatter()
      }
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view

    default:
      preconditionFailure()
    }
  }
}

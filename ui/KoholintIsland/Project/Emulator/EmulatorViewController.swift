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

final class EmulatorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!

  weak var delegate: EmulatorViewControllerDelegate?

  let document: ProjectDocument
  let ramController = NSArrayController()
  let registerStateController = NSArrayController()
  var ramTableView: EditorTableView?
  let instructionAssemblyLabel = CreateLabel()
  let instructionBytesLabel = CreateLabel()
  private let cpuView = LR35902View()

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

  private var programCounterObserver: NSKeyValueObservation?
  private var disassembledSubscriber: AnyCancellable?

  override func loadView() {
    view = NSView()

    // MARK: Views

    let monospacedFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)

    let controls = NSSegmentedControl()
    controls.translatesAutoresizingMaskIntoConstraints = false
    controls.trackingMode = .momentary
    controls.segmentStyle = .smallSquare
    controls.segmentCount = 3
    controls.setImage(NSImage(systemSymbolName: "arrowshape.bounce.forward.fill", accessibilityDescription: nil)!, forSegment: 0)
    controls.setImage(NSImage(systemSymbolName: "arrow.down.to.line.alt", accessibilityDescription: nil)!, forSegment: 1)
    controls.setImage(NSImage(systemSymbolName: "clear", accessibilityDescription: nil)!, forSegment: 2)
    controls.setWidth(40, forSegment: 0)
    controls.setWidth(40, forSegment: 1)
    controls.setWidth(40, forSegment: 2)
    controls.setEnabled(true, forSegment: 0)
    controls.setEnabled(true, forSegment: 1)
    controls.setEnabled(true, forSegment: 2)
    controls.target = self
    controls.action = #selector(performControlAction(_:))
    view.addSubview(controls)

    cpuView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(cpuView)

    let bankLabel = CreateLabel()
    bankLabel.translatesAutoresizingMaskIntoConstraints = false
    bankLabel.stringValue = "bank:"
    bankLabel.font = monospacedFont
    bankLabel.alignment = .right
    view.addSubview(bankLabel)

    let bankTextField = NSTextField()
    bankTextField.translatesAutoresizingMaskIntoConstraints = false
    bankTextField.formatter = UInt8HexFormatter()
    if let cartridge = self.document.gameboy.cartridge {
      bankTextField.stringValue = bankTextField.formatter!.string(for: cartridge.selectedBank)!
    }
    bankTextField.isEditable = false
    bankTextField.identifier = .bank
    bankTextField.font = monospacedFont
    bankTextField.delegate = self
    view.addSubview(bankTextField)

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

    let ramTableView = EditorTableView(elementsController: ramController)
    ramTableView.translatesAutoresizingMaskIntoConstraints = false
    ramTableView.tableView?.delegate = self
    view.addSubview(ramTableView)
    self.ramTableView = ramTableView

    // MARK: Model

    let ramColumns = [
      Column(name: "Address", identifier: .address, width: 50),
      Column(name: "Name", identifier: .variableName, width: 50),
      Column(name: "Value", identifier: .registerValue, width: 40),
      Column(name: "Source", identifier: .registerSourceLocation, width: 65),
      Column(name: "Variable", identifier: .registerVariableAddress, width: 50),
    ]
    for columnInfo in ramColumns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      ramTableView.tableView?.addTableColumn(column)
    }

    registerStateController.addObject("Unknown")
    registerStateController.addObject("Literal")
    registerStateController.addObject("Address")

    // MARK: Layout

    NSLayoutConstraint.activate([
      controls.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      controls.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      controls.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

      cpuView.topAnchor.constraint(equalToSystemSpacingBelow: controls.bottomAnchor, multiplier: 1),
      cpuView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),

      bankLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      bankLabel.firstBaselineAnchor.constraint(equalTo: bankTextField.firstBaselineAnchor),

      bankTextField.leadingAnchor.constraint(equalTo: bankLabel.trailingAnchor),
      bankTextField.widthAnchor.constraint(equalToConstant: 50),
      bankTextField.topAnchor.constraint(equalTo: cpuView.bottomAnchor),

      instructionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
      instructionLabel.topAnchor.constraint(equalTo: bankLabel.bottomAnchor),
      instructionLabel.topAnchor.constraint(equalTo: bankTextField.bottomAnchor),

      instructionAssemblyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionAssemblyLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
      instructionAssemblyLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor),

      instructionBytesLabelHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionBytesLabelHeader.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
      instructionBytesLabelHeader.topAnchor.constraint(equalTo: instructionAssemblyLabel.bottomAnchor),

      instructionBytesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionBytesLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
      instructionBytesLabel.topAnchor.constraint(equalTo: instructionBytesLabelHeader.bottomAnchor),

      ramTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      ramTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      ramTableView.topAnchor.constraint(equalToSystemSpacingBelow: instructionBytesLabel.bottomAnchor, multiplier: 1),
      ramTableView.heightAnchor.constraint(equalToConstant: 220),
    ])

    ramController.sortDescriptors = [
      NSSortDescriptor(key: NSUserInterfaceItemIdentifier.address.rawValue, ascending: true),
    ]

    ramTableView.tableView?.bind(.content, to: ramController, withKeyPath: "arrangedObjects", options: nil)
    ramTableView.tableView?.bind(.selectionIndexes, to: ramController, withKeyPath:"selectionIndexes", options: nil)
    ramTableView.tableView?.bind(.sortDescriptors, to: ramController, withKeyPath: "sortDescriptors", options: nil)

    updateInstructionAssembly()
    updateRegisters()
    updateRAM()

    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        self.updateInstructionAssembly()
      })
  }

  var running = false

  @objc func performControlAction(_ sender: NSSegmentedControl) {
    if sender.selectedSegment == 0 {  // Step forward
      precondition(currentInstruction() != nil)

      // TODO: Step into and through any control flow.

      document.gameboy = document.gameboy.advanceInstruction()

      updateInstructionAssembly()
      updateRegisters()
      updateRAM()

      delegate?.emulatorViewControllerDidStepIn(self)

    } else if sender.selectedSegment == 1 {  // Step into
      running = !running
      if running {
        instructionAssemblyLabel.stringValue = "Running..."
        instructionBytesLabel.stringValue = "Running..."
        DispatchQueue.global(qos: .userInteractive).async {
          while self.running {
            self.document.gameboy = self.document.gameboy.advanceInstruction()

            DispatchQueue.main.sync {
              self.updateRegisters()
              self.updateRAM()
            }
          }
          DispatchQueue.main.sync {
            self.updateInstructionAssembly()
          }
        }
      }
      // TODO: Only allow this if the instruction causes a transfer of control flow.

    } else if sender.selectedSegment == 2 {  // Clear
      var state = document.gameboy.cpu
      for register in LR35902.Instruction.Numeric.registers8 {
        state.clear(register)
      }
      for register in LR35902.Instruction.Numeric.registers16 {
        state.clear(register)
      }
      // TODO: Reset RAM.
      document.gameboy.cpu = state

      updateRegisters()
      updateRAM()
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
    if let addressAndBank = document.gameboy.cpu.machineInstruction.sourceAddressAndBank() {
      // When a machine instruction has been loaded we need to look at it source location rather than the cpu's current
      // pc + bank as the CPU may have already incremented the pc as a result of reading the instruction's opcode.
      return document.disassemblyResults?.disassembly?.instruction(at: addressAndBank.address, in: addressAndBank.bank)
    }
    if let cartridge = document.gameboy.cartridge {
      return document.disassemblyResults?.disassembly?.instruction(at: document.gameboy.cpu.pc, in: cartridge.selectedBank)
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
        bank: cartridge.selectedBank,
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

  func updateRAM() {
    // TODO: Make this handle the various memory regions better.
//    let globalMap = document.configuration.globals.reduce(into: [:]) { accumulator, global in
//      accumulator[global.address] = global
//    }
//    ramController.content = document.memoryUnit.map { address, value -> RAMValue in
//      let globalName = globalMap[address]?.name
//      let valueString = "0x" + value.hexString
//      return RAMValue(address: address,
//                      variableName: globalName,
//                      value: valueString,
//                      sourceLocation: nil,
//                      variableAddress: 0)
//    }
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

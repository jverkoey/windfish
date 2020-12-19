import Foundation
import Combine
import Cocoa

import LR35902

extension NSUserInterfaceItemIdentifier {
  static let programCounter = NSUserInterfaceItemIdentifier("pc")
  static let register = NSUserInterfaceItemIdentifier("name")
  static let registerState = NSUserInterfaceItemIdentifier("state")
  static let registerValue = NSUserInterfaceItemIdentifier("value")
  static let registerSourceLocation = NSUserInterfaceItemIdentifier("sourceLocation")
}

private final class CPURegister: NSObject {
  init(name: String, register: LR35902.Instruction.Numeric, state: String, value: UInt16, sourceLocation: LR35902.Cartridge.Location) {
    self.name = name
    self.register = register
    self.state = state
    self.value = value
    self.sourceLocation = sourceLocation
  }

  @objc dynamic var name: String
  var register: LR35902.Instruction.Numeric
  @objc dynamic var state: String
  @objc dynamic var value: UInt16
  @objc dynamic var sourceLocation: LR35902.Cartridge.Location
}

private final class RAMValue: NSObject {
  init(address: LR35902.Address, state: String, value: UInt16, sourceLocation: LR35902.Cartridge.Location) {
    self.address = address
    self.state = state
    self.value = value
    self.sourceLocation = sourceLocation
  }

  @objc dynamic var address: LR35902.Address
  @objc dynamic var state: String
  @objc dynamic var value: UInt16
  @objc dynamic var sourceLocation: LR35902.Cartridge.Location
}

final class EmulatorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!

  let document: ProjectDocument
  let cpuController = NSArrayController()
  let ramController = NSArrayController()
  let registerStateController = NSArrayController()
  var tableView: NSTableView?
  var ramTableView: EditorTableView?
  let programCounterTextField = NSTextField()
  let instructionAssemblyLabel = CreateLabel()

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
  private var registerObservers: [NSKeyValueObservation] = []
  private var disassembledSubscriber: AnyCancellable?

  override func loadView() {
    view = NSView()

    // MARK: Views

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

    let programCounterLabel = CreateLabel()
    programCounterLabel.translatesAutoresizingMaskIntoConstraints = false
    programCounterLabel.stringValue = "Program counter:"
    programCounterLabel.alignment = .right
    view.addSubview(programCounterLabel)

    programCounterTextField.translatesAutoresizingMaskIntoConstraints = false
    programCounterTextField.formatter = LR35902AddressFormatter()
    programCounterTextField.stringValue = programCounterTextField.formatter!.string(for: document.cpuState.pc)!
    programCounterTextField.identifier = .programCounter
    programCounterTextField.delegate = self
    view.addSubview(programCounterTextField)

    let bankLabel = CreateLabel()
    bankLabel.translatesAutoresizingMaskIntoConstraints = false
    bankLabel.stringValue = "Bank:"
    bankLabel.alignment = .right
    view.addSubview(bankLabel)

    let bankTextField = NSTextField()
    bankTextField.translatesAutoresizingMaskIntoConstraints = false
    bankTextField.formatter = UInt8HexFormatter()
    bankTextField.stringValue = programCounterTextField.formatter!.string(for: document.cpuState.bank)!
    bankTextField.identifier = .bank
    bankTextField.delegate = self
    view.addSubview(bankTextField)

    let instructionLabel = CreateLabel()
    instructionLabel.translatesAutoresizingMaskIntoConstraints = false
    instructionLabel.stringValue = "Instruction:"
    view.addSubview(instructionLabel)

    instructionAssemblyLabel.translatesAutoresizingMaskIntoConstraints = false
    instructionAssemblyLabel.stringValue = "Waiting for disassembly results..."
    instructionAssemblyLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
    view.addSubview(instructionAssemblyLabel)

    let containerView = NSScrollView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true

    let tableView = NSTableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.style = .fullWidth
    tableView.selectionHighlightStyle = .regular
    tableView.delegate = self
    containerView.documentView = tableView
    view.addSubview(containerView)
    self.tableView = tableView

    let ramTableView = EditorTableView(elementsController: ramController)
    ramTableView.translatesAutoresizingMaskIntoConstraints = false
    ramTableView.tableView?.delegate = self
    view.addSubview(ramTableView)
    self.ramTableView = ramTableView

    let textFieldAlignmentGuide = NSLayoutGuide()
    view.addLayoutGuide(textFieldAlignmentGuide)

    // MARK: Model

    let columns = [
      Column(name: "Register", identifier: .register, width: 50),
      Column(name: "State", identifier: .registerState, width: 100),
      Column(name: "Value", identifier: .registerValue, width: 50),
      Column(name: "Source", identifier: .registerSourceLocation, width: 50),
    ]
    for columnInfo in columns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      tableView.addTableColumn(column)
    }

    let ramColumns = [
      Column(name: "Address", identifier: .address, width: 50),
      Column(name: "State", identifier: .registerState, width: 100),
      Column(name: "Value", identifier: .registerValue, width: 50),
      Column(name: "Source", identifier: .registerSourceLocation, width: 50),
    ]
    for columnInfo in ramColumns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      ramTableView.tableView?.addTableColumn(column)
    }

    let registers = [
      CPURegister(name: "a", register: .a, state: "Unknown", value: 0, sourceLocation: 0),
      CPURegister(name: "b", register: .b, state: "Unknown", value: 0, sourceLocation: 0),
      CPURegister(name: "c", register: .c, state: "Unknown", value: 0, sourceLocation: 0),
      CPURegister(name: "d", register: .d, state: "Unknown", value: 0, sourceLocation: 0),
      CPURegister(name: "e", register: .e, state: "Unknown", value: 0, sourceLocation: 0),
      CPURegister(name: "h", register: .h, state: "Unknown", value: 0, sourceLocation: 0),
      CPURegister(name: "l", register: .l, state: "Unknown", value: 0, sourceLocation: 0),
      CPURegister(name: "sp", register: .sp, state: "Unknown", value: 0, sourceLocation: 0),
    ]
    let didChangeRegister: (CPURegister) -> Void = { [weak self] register in
      guard let self = self else {
        return
      }
      switch register.state {
      case "Unknown":
        self.document.cpuState.clear(register.register)
      case "Literal":
        if LR35902.Instruction.Numeric.registers8.contains(register.register) {
          self.document.cpuState[register.register] = LR35902.CPUState.RegisterState<UInt8>(value: .literal(UInt8(register.value)), sourceLocation: register.sourceLocation)
        } else if LR35902.Instruction.Numeric.registers16.contains(register.register) {
          self.document.cpuState[register.register] = LR35902.CPUState.RegisterState<UInt16>(value: .literal(register.value), sourceLocation: register.sourceLocation)
        }
      case "Address":
        if LR35902.Instruction.Numeric.registers8.contains(register.register) {
          self.document.cpuState[register.register] = LR35902.CPUState.RegisterState<UInt8>(value: .variable(register.value), sourceLocation: register.sourceLocation)
        } else if LR35902.Instruction.Numeric.registers16.contains(register.register) {
          self.document.cpuState[register.register] = LR35902.CPUState.RegisterState<UInt16>(value: .variable(register.value), sourceLocation: register.sourceLocation)
        }
      default:
        preconditionFailure()
      }
    }
    for register in registers {
      registerObservers.append(contentsOf: [
        register.observe(\.state) { register, _ in didChangeRegister(register) },
        register.observe(\.value) { register, _ in didChangeRegister(register) },
        register.observe(\.sourceLocation) { register, _ in didChangeRegister(register) },
      ])
    }
    cpuController.add(contentsOf: registers)
    cpuController.setSelectionIndexes(IndexSet())

    registerStateController.addObject("Unknown")
    registerStateController.addObject("Literal")
    registerStateController.addObject("Address")

    // MARK: Layout

    NSLayoutConstraint.activate([
      controls.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      controls.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      controls.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

      programCounterLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      programCounterLabel.topAnchor.constraint(equalToSystemSpacingBelow: controls.bottomAnchor, multiplier: 1),

      bankLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      bankLabel.topAnchor.constraint(equalTo: programCounterLabel.bottomAnchor),

      textFieldAlignmentGuide.leadingAnchor.constraint(equalTo: programCounterLabel.trailingAnchor),
      textFieldAlignmentGuide.leadingAnchor.constraint(equalTo: bankLabel.trailingAnchor),
      textFieldAlignmentGuide.widthAnchor.constraint(equalToConstant: 8),

      programCounterTextField.leadingAnchor.constraint(equalTo: textFieldAlignmentGuide.trailingAnchor),
      programCounterTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      programCounterTextField.topAnchor.constraint(equalTo: programCounterLabel.topAnchor),
      bankLabel.topAnchor.constraint(equalTo: programCounterTextField.bottomAnchor),

      bankTextField.leadingAnchor.constraint(equalTo: textFieldAlignmentGuide.trailingAnchor),
      bankTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      bankTextField.topAnchor.constraint(equalTo: bankLabel.topAnchor),

      instructionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
      instructionLabel.topAnchor.constraint(equalTo: bankLabel.bottomAnchor),
      instructionLabel.topAnchor.constraint(equalTo: bankTextField.bottomAnchor),

      instructionAssemblyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      instructionAssemblyLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
      instructionAssemblyLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor),

      containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      containerView.topAnchor.constraint(equalToSystemSpacingBelow: instructionAssemblyLabel.bottomAnchor, multiplier: 1),
      containerView.heightAnchor.constraint(equalToConstant: 220),

      ramTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      ramTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      ramTableView.topAnchor.constraint(equalToSystemSpacingBelow: containerView.bottomAnchor, multiplier: 1),
      ramTableView.heightAnchor.constraint(equalToConstant: 220),
    ])

    ramController.sortDescriptors = [
      NSSortDescriptor(key: NSUserInterfaceItemIdentifier.address.rawValue, ascending: true),
    ]

    tableView.bind(.content, to: cpuController, withKeyPath: "arrangedObjects", options: nil)
    tableView.bind(.selectionIndexes, to: cpuController, withKeyPath:"selectionIndexes", options: nil)
    tableView.bind(.sortDescriptors, to: cpuController, withKeyPath: "sortDescriptors", options: nil)

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

  @objc func performControlAction(_ sender: NSSegmentedControl) {
    if sender.selectedSegment == 0 {  // Step forward
      guard let instruction = currentInstruction() else {
        return
      }

      // TODO: Step into and through any control flow.

      document.cpuState = document.cpuState.emulate(instruction: instruction, followControlFlow: true)
      programCounterTextField.objectValue = document.cpuState.pc
      updateInstructionAssembly()
      updateRegisters()
      updateRAM()
    } else if sender.selectedSegment == 1 {  // Step into
      // TODO: Only allow this if the instruction causes a transfer of control flow.

    } else if sender.selectedSegment == 2 {  // Clear
      var state = document.cpuState
      for register in LR35902.Instruction.Numeric.registers8 {
        state.clear(register)
      }
      for register in LR35902.Instruction.Numeric.registers16 {
        state.clear(register)
      }
      state.ram.removeAll()
      document.cpuState = state

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
    case .bank:
      document.cpuState.bank = textField.objectValue as! LR35902.Bank
    case .programCounter:
      document.cpuState.pc = textField.objectValue as! LR35902.Address
    default:
      preconditionFailure()
    }

    updateInstructionAssembly()
  }

  private func currentInstruction() -> LR35902.Instruction? {
    return document.disassemblyResults?.disassembly?.instruction(at: document.cpuState.pc, in: document.cpuState.bank)
  }

  private func updateInstructionAssembly() {
    guard let disassembly = document.disassemblyResults?.disassembly else {
      return
    }
    guard let instruction = currentInstruction() else {
      instructionAssemblyLabel.stringValue = "No instruction detected"
      return
    }

    let context = RGBDSDisassembler.Context(
      address: document.cpuState.pc,
      bank: document.cpuState.bank,
      disassembly: disassembly,
      argumentString: nil
    )
    let statement = RGBDSDisassembler.statement(for: instruction, with: context)
    instructionAssemblyLabel.stringValue = statement.formattedString
  }

  func updateRegisters() {
    for register in cpuController.arrangedObjects as! [CPURegister] {
      if LR35902.Instruction.Numeric.registers8.contains(register.register) {
        let value: LR35902.CPUState.RegisterState<UInt8>? = self.document.cpuState[register.register]

        register.sourceLocation = value?.sourceLocation ?? 0

        switch value?.value {
        case .none:
          register.state = "Unknown"
          register.value = 0
        case .literal(let value):
          register.state = "Literal"
          register.value = UInt16(value)
        case .variable(let address):
          register.state = "Address"
          register.value = address
        }
      } else if LR35902.Instruction.Numeric.registers16.contains(register.register) {
        let value: LR35902.CPUState.RegisterState<UInt16>? = self.document.cpuState[register.register]

        register.sourceLocation = value?.sourceLocation ?? 0

        switch value?.value {
        case .none:
          register.state = "Unknown"
          register.value = 0
        case .literal(let value):
          register.state = "Literal"
          register.value = value
        case .variable(let address):
          register.state = "Address"
          register.value = address
        }
      }
    }
  }

  func updateRAM() {
    ramController.content = document.cpuState.ram.map { address, value -> RAMValue in
      switch value.value {
      case .literal(let literalValue):
        return RAMValue(address: address, state: "Literal", value: UInt16(literalValue), sourceLocation: value.sourceLocation)
      case .variable(let variableAddress):
        return RAMValue(address: address, state: "Address", value: variableAddress, sourceLocation: value.sourceLocation)
      }
    }
  }
}

extension EmulatorViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let tableColumn = tableColumn else {
      preconditionFailure()
    }

    switch tableColumn.identifier {
    case .register:
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
    case .registerState:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      let view: TypeTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        view = TypeTableCellView()
        view.identifier = identifier
      }
      view.popupButton.bind(.content, to: registerStateController, withKeyPath: "arrangedObjects", options: nil)
      view.popupButton.bind(.selectedObject, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    case .registerValue, .registerSourceLocation, .address:
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

import Foundation

final class DebuggingViewController: NSViewController {
  let project: Project

  @IBOutlet var debugConsoleView: NSView?
  @IBOutlet var consoleInput: NSTextField?
  @IBOutlet var consoleOutput: NSTextView?

  @IBOutlet var pcLabel: FixedWidthTextView?
  @IBOutlet var spLabel: FixedWidthTextView?
  @IBOutlet var aLabel: FixedWidthTextView?
  @IBOutlet var fLabel: FixedWidthTextView?
  @IBOutlet var bLabel: FixedWidthTextView?
  @IBOutlet var cLabel: FixedWidthTextView?
  @IBOutlet var dLabel: FixedWidthTextView?
  @IBOutlet var eLabel: FixedWidthTextView?
  @IBOutlet var hLabel: FixedWidthTextView?
  @IBOutlet var lLabel: FixedWidthTextView?

  var lastConsoleOutput: String?

  init(project: Project) {
    self.project = project

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()

    Bundle.main.loadNibNamed("DebugConsoleView", owner: self, topLevelObjects: nil)

    guard let debugConsoleView = debugConsoleView else {
      fatalError()
    }
    debugConsoleView.frame = view.bounds
    debugConsoleView.autoresizingMask = [.width, .height]
    view.addSubview(debugConsoleView)

    pcLabel?.formatter = LR35902AddressFormatter()
    spLabel?.formatter = LR35902AddressFormatter()
    aLabel?.formatter = UInt8HexFormatter()
    fLabel?.formatter = FlagsFormatter()
    bLabel?.formatter = UInt8HexFormatter()
    cLabel?.formatter = UInt8HexFormatter()
    dLabel?.formatter = UInt8HexFormatter()
    eLabel?.formatter = UInt8HexFormatter()
    hLabel?.formatter = UInt8HexFormatter()
    lLabel?.formatter = UInt8HexFormatter()
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    project.logObservers.append(self)
    project.emulationObservers.add(self)
  }
}

extension DebuggingViewController: LogObserver {
  func didLog() {
    appendPendingOutput()
  }

  private func appendPendingOutput() {
    guard let consoleOutput = consoleOutput else {
      return
    }

    let pendingConsoleOutput: NSAttributedString?
    project.consoleOutputLock.lock()
    if project.pendingConsoleOutput.length > 0 {
      pendingConsoleOutput = project.pendingConsoleOutput
      project.pendingConsoleOutput = NSMutableAttributedString()
    } else {
      pendingConsoleOutput = nil
    }
    project.consoleOutputLock.unlock()

    if let pendingConsoleOutput = pendingConsoleOutput {
      consoleOutput.textStorage?.append(pendingConsoleOutput)
      consoleOutput.scrollToEndOfDocument(nil)
    }
  }
}

extension DebuggingViewController: EmulationObservers {
  func emulationDidAdvance() {
    pcLabel?.integerValue = Int(truncatingIfNeeded: project.sameboy.pc)
    spLabel?.integerValue = Int(truncatingIfNeeded: project.sameboy.sp)
    aLabel?.integerValue  = Int(truncatingIfNeeded: project.sameboy.a)
    fLabel?.integerValue  = Int(truncatingIfNeeded: project.sameboy.f)
    bLabel?.integerValue  = Int(truncatingIfNeeded: project.sameboy.b)
    cLabel?.integerValue  = Int(truncatingIfNeeded: project.sameboy.c)
    dLabel?.integerValue  = Int(truncatingIfNeeded: project.sameboy.d)
    eLabel?.integerValue  = Int(truncatingIfNeeded: project.sameboy.e)
    hLabel?.integerValue  = Int(truncatingIfNeeded: project.sameboy.h)
    lLabel?.integerValue  = Int(truncatingIfNeeded: project.sameboy.l)
  }

  func emulationDidStart() {}

  func emulationDidStop() {}
}

// MARK: - Actions

extension DebuggingViewController {
  @IBAction func consoleInput(_ sender: Any?) {
    guard let textField = sender as? NSTextField else {
      return
    }

    let line: String
    if textField.stringValue.isEmpty, let lastConsoleOutput = lastConsoleOutput {
      line = lastConsoleOutput
    } else {
      line = textField.stringValue
    }
    project.nextDebuggerCommand = line
    lastConsoleOutput = line
    project.sameboyDebuggerSemaphore.signal()

    textField.stringValue = ""
  }
}

import Foundation

final class DebuggingViewController: NSViewController {
  @IBOutlet var debugConsoleView: NSView?
  @IBOutlet var splitView: NSSplitView?
  @IBOutlet var consoleInput: NSTextField?

  var lastConsoleOutput: String?

  override func loadView() {
    view = NSView()

    Bundle.main.loadNibNamed("DebugConsoleView", owner: self, topLevelObjects: nil)

    guard let debugConsoleView = debugConsoleView else {
      fatalError()
    }
    debugConsoleView.frame = view.bounds
    debugConsoleView.autoresizingMask = [.width, .height]
    view.addSubview(debugConsoleView)
  }
}

extension DebuggingViewController {
  @IBAction func consoleInput(_ sender: Any?) {
    guard let textField = sender as? NSTextField else {
      return
    }
    guard let document = projectDocument else {
      return
    }

    let line: String
    if textField.stringValue.isEmpty, let lastConsoleOutput = lastConsoleOutput {
      line = lastConsoleOutput
    } else {
      line = textField.stringValue
    }
    document.nextDebuggerCommand = line
    document.sameboyDebuggerSemaphore.signal()

    textField.stringValue = ""
  }
}

extension DebuggingViewController: NSSplitViewDelegate {
  func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
    return 300
  }

  func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
    return splitView.bounds.size.width - 200
  }
}

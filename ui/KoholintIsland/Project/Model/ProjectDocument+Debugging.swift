import Foundation

extension ProjectDocument {
  @objc func stepForward(_ sender: Any?) {
    guard sameboy.gb.pointee.debug_stopped else {
      return // Emulation must be stopped first.
    }

    nextDebuggerCommand = "next"
    sameboyDebuggerSemaphore.signal()
  }

  @objc func stepInto(_ sender: Any?) {
    guard sameboy.gb.pointee.debug_stopped else {
      return // Emulation must be stopped first.
    }

    nextDebuggerCommand = "step"
    sameboyDebuggerSemaphore.signal()
  }

  @objc func toggleEmulation(_ sender: Any?) {
    sameboy.gb.pointee.debug_stopped = !sameboy.gb.pointee.debug_stopped

    if !sameboy.gb.pointee.debug_stopped {
      // Disconnect the debugger repl.
      nextDebuggerCommand = nil
      sameboyDebuggerSemaphore.signal()
    }

    // TODO: Signal to the UI of this state change.
//    self.toggleEmulationButton?.state = document.sameboy.gb.pointee.debug_stopped ? .off : .on
  }

  @objc func pauseEmulation(_ sender: Any?) {
    sameboy.debuggerBreak()
  }
}

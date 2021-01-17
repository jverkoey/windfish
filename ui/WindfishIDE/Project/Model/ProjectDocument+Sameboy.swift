import Cocoa

extension Project: SameboyEmulatorDelegate {
  // MARK: - EmulatorDelegate
  func willRun() {
    sameboy.lcdOutput = sameboyView.pixels
  }

  func didRun() {

  }

  var isMuted: Bool {
    return false
  }

  var isRewinding: Bool {
    return false
  }

  // MARK: - CallbackBridgeDelegate

  func vblank() {
    sameboyView.flip()
    sameboy.lcdOutput = sameboyView.pixels

    DispatchQueue.main.async {
      // Ensure that all observers execute on the main thread.
      self.emulationObservers.allObjects.forEach { $0.emulationDidAdvance() }
    }
  }

  func getDebuggerInput() -> String? {
    emulating = false

    DispatchQueue.main.async {
      // Ensure that all observers execute on the main thread.
      self.emulationObservers.allObjects.forEach {
        $0.emulationDidAdvance()
      }
      self.emulationObservers.allObjects.forEach {
        $0.emulationDidStop()
      }
    }

    sameboyDebuggerSemaphore.wait()
    let nextDebuggerCommand = self.nextDebuggerCommand
    self.nextDebuggerCommand = nil
    emulating = true

    // Create spacing between the last command output.
    log("\n> \(nextDebuggerCommand ?? "")\n", with: [])

    DispatchQueue.main.async {
      // Ensure that all observers execute on the main thread.
      self.emulationObservers.allObjects.forEach {
        $0.emulationDidStart()
      }
    }
    return nextDebuggerCommand
  }

  func log(_ log: String, with attributes: GBLogAttributes) {
    let font = NSFont.userFixedPitchFont(ofSize: 12)!
    let underline: NSUnderlineStyle
    if attributes.contains(.dashedUnderline) {
      underline = [.patternDot, .single]
    } else if attributes.contains(.underline) {
      underline = .single
    } else {
      underline = []
    }
    let attributedString = NSMutableAttributedString(string: log, attributes: [
      .font: font,
      .foregroundColor: NSColor.textColor,
      .underlineStyle: underline.rawValue
    ])
    consoleOutputLock.lock()
    pendingConsoleOutput.append(attributedString)
    consoleOutputLock.unlock()

    DispatchQueue.main.async {
      self.logObservers.forEach {
        $0.didLog()
      }
    }
  }
//    [console_output_lock lock];
//    if (!pending_console_output) {
//        pending_console_output = attributed;
//    }
//    else {
//        [pending_console_output appendAttributedString:attributed];
//    }
//
//    if (![console_output_timer isValid]) {
//        console_output_timer = [NSTimer timerWithTimeInterval:(NSTimeInterval)0.05 target:self selector:@selector(appendPendingOutput) userInfo:nil repeats:NO];
//        [[NSRunLoop mainRunLoop] addTimer:console_output_timer forMode:NSDefaultRunLoopMode];
//    }
//
//    [console_output_lock unlock];
//
//    /* Make sure mouse is not hidden while debugging */
//    self.view.mouseHidingEnabled = NO;
//}

}

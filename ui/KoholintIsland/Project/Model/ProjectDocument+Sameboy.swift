import Cocoa

extension ProjectDocument: EmulatorDelegate {
  // MARK: - EmulatorDelegate
  func willRun() {
    sameboy.lcdOutput = sameboyView.pixels()
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

  func loadBootROM(_ type: GB_boot_rom_t) {
    let names: [UInt32: String] = [
      GB_BOOT_ROM_DMG0.rawValue: "dmg0_boot",
      GB_BOOT_ROM_DMG.rawValue: "dmg_boot",
      GB_BOOT_ROM_MGB.rawValue: "mgb_boot",
      GB_BOOT_ROM_SGB.rawValue: "sgb_boot",
      GB_BOOT_ROM_SGB2.rawValue: "sgb2_boot",
      GB_BOOT_ROM_CGB0.rawValue: "cgb0_boot",
      GB_BOOT_ROM_CGB.rawValue: "cgb_boot",
      GB_BOOT_ROM_AGB.rawValue: "agb_boot",
    ]
    sameboy.loadBootROM(Bundle.main.path(forResource: names[type.rawValue], ofType: "bin")!)
  }

  func gotNewSample(_ sample: UnsafeMutablePointer<GB_sample_t>) {
    
  }

  func vblank() {
    sameboyView.flip()
    sameboy.lcdOutput = sameboyView.pixels()

    DispatchQueue.main.async {
      if let vramWindow = self.vramWindow, vramWindow.isVisible {
        self.reloadVRAMData(nil)
      }
      // Ensure that all observers execute on the main thread.
      self.emulationObservers.forEach { $0.emulationDidAdvance() }
    }
  }

  func getDebuggerInput() -> String? {
    emulating = false

    DispatchQueue.main.async {
      // Ensure that all observers execute on the main thread.
      self.emulationObservers.forEach {
        $0.emulationDidAdvance()
      }
      self.emulationObservers.forEach {
        $0.emulationDidStop()
      }
    }

    sameboyDebuggerSemaphore.wait()
    let nextDebuggerCommand = self.nextDebuggerCommand
    self.nextDebuggerCommand = nil
    emulating = true

    // Create spacing between the last command output.
    log("\n> \(nextDebuggerCommand ?? "")\n", with: GB_log_attributes(0))

    DispatchQueue.main.async {
      // Ensure that all observers execute on the main thread.
      self.emulationObservers.forEach {
        $0.emulationDidStart()
      }
    }
    return nextDebuggerCommand
  }

  func log(_ log: String, with attributes: GB_log_attributes) {
    let font = NSFont.userFixedPitchFont(ofSize: 12)!
    let underline: NSUnderlineStyle
    if (attributes.rawValue & GB_LOG_UNDERLINE_MASK.rawValue) != 0 {
      underline = (attributes.rawValue & GB_LOG_DASHED_UNDERLINE.rawValue) != 0 ? [.patternDot, .single] : .single
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

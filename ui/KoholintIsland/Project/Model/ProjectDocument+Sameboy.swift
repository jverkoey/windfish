import Cocoa

extension ProjectDocument: EmulatorDelegate {
  // MARK: - EmulatorDelegate
  func willRun() {

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

  }
}

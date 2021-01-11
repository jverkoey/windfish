import Foundation
import Cocoa

final class PPUViewController: NSViewController {
  let registersView = PPURegistersView()

  override func loadView() {
    view = NSView()

    registersView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(registersView)

    NSLayoutConstraint.activate([
      registersView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      registersView.topAnchor.constraint(equalTo: view.topAnchor),
    ])
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let document = projectDocument else {
      fatalError()
    }
    document.emulationObservers.append(self)
    registersView.update(with: document.gameboy.ppu)
  }
}

extension PPUViewController: EmulationObservers {
  func emulationDidAdvance(screenImage: NSImage, tileDataImage: NSImage, fps: Double?, ips: Double?) {
    guard let document = projectDocument else {
      fatalError()
    }
    registersView.update(with: document.gameboy.ppu)
  }

  func emulationDidStart() {}
  func emulationDidStop() {}
}

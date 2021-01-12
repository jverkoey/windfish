import Foundation
import Cocoa

import Windfish

// TODO: Rename to EmulationObserver
protocol EmulationObservers {
  func emulationDidAdvance(screenImage: NSImage, tileDataImage: NSImage, fps: Double?, ips: Double?)
  func emulationDidStart()
  func emulationDidStop()
}

private final class EmulationBreakpointContext: NSObject {
  @objc dynamic var pc: LR35902.Address = 0
  @objc dynamic var bank: Gameboy.Cartridge.Bank = 0
}

extension ProjectDocument {
  /** Advances the emulation until the statement following the current one is reached. */
  func stepForward() {
    guard let spec = gameboy.cpu.machineInstruction.spec else {
      gameboy.advance()
      self.emulationObservers.forEach { $0.emulationDidStop() }
      return
    }
    // If we're about to make a call...
    if case .call = spec {
      let nextAddress = gameboy.cpu.machineInstruction.sourceAddress()! + LR35902.InstructionSet.widths[spec]!.total
      // ..then advance until we're ready to execute the next statement.
      run { gameboy -> Bool in
        gameboy.cpu.machineInstruction.sourceAddress() == nextAddress
      }

      // If we're in a macro...
    } else if let sourceAddressAndBank = gameboy.cpu.machineInstruction.sourceAddressAndBank(),
              let disassemblyResults = disassemblyResults,
              let lineNumber = disassemblyResults.lineFor(address: sourceAddressAndBank.address, bank: sourceAddressAndBank.bank),
              let line = disassemblyResults.bankLines?[(sourceAddressAndBank.address < 0x4000) ? 0 : sourceAddressAndBank.bank]?[lineNumber],
              case .macro = line.semantic,
              let data = line.data {
      // ...then advance until we're out of the macro's instructions.
      let range = gameboy.cpu.machineInstruction.sourceAddress()!..<(gameboy.cpu.machineInstruction.sourceAddress()! + LR35902.Address(truncatingIfNeeded: data.count))
      run { gameboy -> Bool in
        !range.contains(gameboy.cpu.machineInstruction.sourceAddress()!)
      }

    } else {
      stepInto()
    }
  }

  /** Advances the emulation by one instruction. */
  func stepInto() {
    guard gameboy.cpu.machineInstruction.spec != nil else {
      gameboy.advance()
      self.emulationObservers.forEach { $0.emulationDidStop() }
      return
    }
    let initialAddress = gameboy.cpu.machineInstruction.sourceAddress()!
    // Advance until an interrupt happens.
    run { gameboy -> Bool in
      gameboy.cpu.machineInstruction.sourceAddress() != initialAddress
    }
  }

  /** Advances the emulation by a single machine cycle. */
  func advance() {
    guard gameboy.cpu.machineInstruction.spec != nil else {
      gameboy.advance()
      self.emulationObservers.forEach { $0.emulationDidStop() }
      return
    }
    var didAdvance = false
    run { gameboy -> Bool in
      if !didAdvance {
        didAdvance = true
        return false  // Advance once.
      }
      return true
    }
  }

  func informObserversOfEmulationAdvance(screenImage: NSImage, tileDataImage: NSImage, fps: Double?, ips: Double?) {
    self.emulationObservers.forEach {
      $0.emulationDidAdvance(screenImage: screenImage, tileDataImage: tileDataImage, fps: fps, ips: ips)
    }
  }

  func stop() {
    emulating = false
  }

  func run(breakpoint: ((Gameboy) -> Bool)? = nil) {
    if emulating {
      return  // Ignore subsequent invocations.
    }
    emulating = true

    emulationObservers.forEach { $0.emulationDidStart() }

    let breakpointContext = EmulationBreakpointContext()

    DispatchQueue.global(qos: .userInteractive).async {
      let gameboy = self.gameboy

      let breakpointEvaluator: (() -> Bool)?
      if let breakpoint = breakpoint {
        breakpointEvaluator = { breakpoint(gameboy) }
      } else if let breakpointPredicate = self.breakpointPredicate {
        breakpointEvaluator = { breakpointPredicate.evaluate(with: breakpointContext) }
      } else {
        breakpointEvaluator = nil
      }

      var start = DispatchTime.now()
      var lastFrameTick = DispatchTime.now()
      var machineCycle: UInt64 = 0
      var frames: UInt64 = 0

      breakpointContext.pc = gameboy.cpu.pc
      breakpointContext.bank = gameboy.cartridge!.selectedBank

      while !(breakpointEvaluator?() ?? true) && self.emulating {
        gameboy.advance()

        breakpointContext.pc = gameboy.cpu.pc
        breakpointContext.bank = gameboy.cartridge!.selectedBank

        machineCycle += 1

        if self.lastVblankCounter != gameboy.ppu.vblankCounter {
          let tileDataImage = self.tileDataImage
          let screenImage = self.screenImage

          self.vblankHistory.append(screenImage)

          let frameDeltaSeconds = (DispatchTime.now().uptimeNanoseconds - lastFrameTick.uptimeNanoseconds)
          let frameLength: UInt64 = 16_666_666
          if frameDeltaSeconds < frameLength {
            usleep(useconds_t((frameLength - frameDeltaSeconds) / 1000))
          }

          lastFrameTick = DispatchTime.now()

          DispatchQueue.main.sync {
            frames += 1
            let deltaSeconds = Double((DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds)) / 1_000_000_000
            let instructionsPerSecond = Double(machineCycle) / deltaSeconds
            let framesPerSecond = Double(frames) / deltaSeconds

            self.informObserversOfEmulationAdvance(screenImage: screenImage, tileDataImage: tileDataImage, fps: framesPerSecond, ips: instructionsPerSecond)
          }
        }
      }

      // When emulation was terminated we might have ended mid-way through an instruction, so we run until the current
      // instruction concludes.
      // TODO: Don't advance if we've just loaded the instruction (i.e. cycles == 0)
      if !self.emulating {
        // Advance to the next full instruction.
        gameboy.advanceInstruction()
      }

      let tileDataImage = self.tileDataImage
      let screenImage = self.screenImage
      DispatchQueue.main.sync {
        self.emulating = false

        self.informObserversOfEmulationAdvance(screenImage: screenImage, tileDataImage: tileDataImage, fps: nil, ips: nil)
        self.emulationObservers.forEach { $0.emulationDidStop() }
      }
    }
  }

  func writeImageHistory(to filename: String) {
    let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let path = documentsDirectoryPath.appending(filename)
    let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
    let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.016]] as CFDictionary?
    let lastFrameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 2]] as CFDictionary?
    let cfURL = URL(fileURLWithPath: path) as CFURL
    Swift.print(cfURL)
    if let destination = CGImageDestinationCreateWithURL(cfURL, kUTTypeGIF, vblankHistory.count, nil) {
      CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
      for image in vblankHistory {
        CGImageDestinationAddImage(destination, image.asCGImage()!, image == vblankHistory.last ? lastFrameProperties : gifProperties)
      }
      CGImageDestinationFinalize(destination)
    }
  }

  private var screenImage: NSImage {
    if lastVblankCounter != gameboy.ppu.vblankCounter {
      lastVBlankImage = gameboy.takeScreenshot()
      lastVblankCounter = gameboy.ppu.vblankCounter
    }
    return lastVBlankImage!
  }

  private var tileDataImage: NSImage {
    if lastTileDataCounter != gameboy.ppu.tileDataCounter {
      lastTileDataImage = gameboy.takeSnapshotOfTileData()
      lastTileDataCounter = gameboy.ppu.tileDataCounter
    }
    return lastTileDataImage!
  }
}

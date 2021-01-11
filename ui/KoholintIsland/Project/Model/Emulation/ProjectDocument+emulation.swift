import Foundation
import Cocoa

import Windfish

protocol EmulationObservers {
  func emulationDidAdvance(screenImage: NSImage, tileDataImage: NSImage, fps: Double?, ips: Double?)
  func emulationDidStart()
  func emulationDidStop()
}

extension ProjectDocument {
  /** Advances the emulation until the statement following the current one is reached. */
  func stepForward() {
    if emulating {
      return  // Ignore subsequent invocations.
    }
    emulating = true

    emulationObservers.forEach { $0.emulationDidStart() }

    DispatchQueue.global(qos: .userInteractive).async {
      let gameboy = self.gameboy
      if case .call = gameboy.cpu.machineInstruction.spec {
        let nextAddress = gameboy.cpu.machineInstruction.sourceAddress()! + LR35902.InstructionSet.widths[gameboy.cpu.machineInstruction.spec!]!.total
        // Advance until we're ready to execute the next statement after the call.

        // TODO: Use the "run" invocation with a breakpoint condition instead so that we get fps and recording.
        repeat {
          gameboy.advanceInstruction()
        } while self.emulating && gameboy.cpu.machineInstruction.sourceAddress() != nextAddress
      } else if case .halt = gameboy.cpu.machineInstruction.spec {
        let initialAddress = gameboy.cpu.machineInstruction.sourceAddress()!
        // Advance until an interrupt happens.

        // TODO: Use the "run" invocation with a breakpoint condition instead so that we get fps and recording.
        repeat {
          gameboy.advanceInstruction()
        } while self.emulating && gameboy.cpu.machineInstruction.sourceAddress() == initialAddress
      } else {
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

  /** Advances the emulation by one instruction. */
  func stepInto() {
    if emulating {
      return  // Ignore subsequent invocations.
    }
    emulating = true

    emulationObservers.forEach { $0.emulationDidStart() }

    DispatchQueue.global(qos: .userInteractive).async {
      let gameboy = self.gameboy
      gameboy.advanceInstruction()

      let tileDataImage = self.tileDataImage
      let screenImage = self.screenImage

      DispatchQueue.main.sync {
        self.emulating = false
        self.informObserversOfEmulationAdvance(screenImage: screenImage, tileDataImage: tileDataImage, fps: nil, ips: nil)
        self.emulationObservers.forEach { $0.emulationDidStop() }
      }
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

  func run() {
    if emulating {
      return  // Ignore subsequent invocations.
    }
    emulating = true

    emulationObservers.forEach { $0.emulationDidStart() }

    DispatchQueue.global(qos: .userInteractive).async {
      let gameboy = self.gameboy

      var start = DispatchTime.now()
      var lastFrameTick = DispatchTime.now()
      var machineCycle: UInt64 = 0
      var frames: UInt64 = 0
      while self.emulating {
        gameboy.advance()

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

      // Advance to the next full instruction.
      gameboy.advanceInstruction()
      let tileDataImage = self.tileDataImage
      let screenImage = self.screenImage
      DispatchQueue.main.sync {
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

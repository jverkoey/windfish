import Foundation

// References:
// - https://news.ycombinator.com/item?id=13291588
//   - Interesting question brought up here of "How was the game boy able to do the OAM scan in 20 cycles?"

extension LCDController {
  final class OAMSearchMode {
    init(oam: OAM, registers: LCDRegisters) {
      self.oam = oam
      self.registers = registers
    }
    var intersectedOAMs: [OAM.Sprite] = []

    private let oam: OAM
    private let registers: LCDRegisters

    private var didSearch = false
    private var cycles = 0

    /** Starts the mode. */
    func start() {
      intersectedOAMs = []
      didSearch = false
    }

    /** Executes a single machine cycle.  */
    func advance(memory: AddressableMemory) -> LCDCMode? {
      cycles += 1

      // The search is performed in a single machine cycle because there are no apparent interactions between OAM search
      // and other parts of the hardware that require per-cycle emulation.
      if didSearch {
        return cycles >= LCDController.searchingOAMLength ? .transferringToLCDDriver : nil
      }

      // TODO: Implement the OAM Search CPU Bug outlined in "The Ultimate Game Boy Talk (33c3)"
      // - https://youtu.be/HyzD8pNlpwI?t=2814

      for sprite in oam.sprites {
        let yPosition = registers.ly + 16
        // Only yPosition is evaluated against the sprite; x appears to have no impact on the selection of sprites.
        // - https://github.com/trekawek/coffee-gb/blob/088b86fb17109b8cac98e6394108b3561f443d54/src/main/java/eu/rekawek/coffeegb/gpu/phase/OamSearch.java#L88-L91
        // - https://github.com/LIJI32/SameBoy/blob/29a3b18186c181399f4b99b9111ca9d8b5726886/Core/display.c#L456-L459
        // Note that this contracts the oam.x != 0 shown in "The Ultimate Game Boy Talk":
        // - https://youtu.be/HyzD8pNlpwI?t=2784
        if sprite.y <= yPosition && yPosition < sprite.y + registers.spriteSize.height() {
          intersectedOAMs.append(sprite)
        }
      }
      didSearch = true

      return nil
    }
  }
}

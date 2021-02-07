import Foundation

import LR35902

public final class Gameboy {
  /** A representation of a specific address either in the cartridge ROM or in memory. */
  public enum SourceLocation: Equatable {
    /** An address in the cartridge's ROM data. */
    case cartridge(Cartridge.Location)

    /** An address in the Gameboy's memory. */
    case memory(LR35902.Address)
  }
}

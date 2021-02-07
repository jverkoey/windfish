import Cocoa

import LR35902
import Windfish

class VRAMWindowController: NSWindowController {
  var project: Project! {
    didSet {
      oldValue?.emulationObservers.remove(self)
      project.emulationObservers.add(self)
    }
  }

  @IBOutlet var vramTabView: NSTabView?
  @IBOutlet var paletteTableView: NSTableView?
  @IBOutlet var spritesTableView: NSTableView?

  @IBOutlet var gridButton: NSButton?

  @IBOutlet var tilesetPaletteButton: NSPopUpButton?
  @IBOutlet var tilesetImageView: GBImageView?

  @IBOutlet var tilemapImageView: GBImageView?
  @IBOutlet var tilemapPaletteButton: NSPopUpButton?
  @IBOutlet var tilemapMapButton: NSPopUpButton?
  @IBOutlet var tilemapSetButton: NSPopUpButton?
  var oamInfo = ContiguousArray<GBOAMInfo>(repeating: GBOAMInfo(), count: 40)
  var oamUpdating = false
  var oamCount: UInt8 = 0
  var oamHeight: UInt8 = 0
}

extension VRAMWindowController {
  @IBAction func vramTabChanged(_ sender: Any?) {
    guard let segmentedControl = sender as? NSSegmentedControl else {
      return
    }
    guard let vramWindow = window,
          let vramTabView = vramTabView,
          let vramWindowContentView = vramWindow.contentView else {
      return
    }
    vramTabView.selectTabViewItem(at: segmentedControl.selectedSegment)
    reloadVRAMData(nil)
    //    [self.vramTabView.selectedTabViewItem.view addSubview:self.gridButton];
    //    self.gridButton.hidden = [sender selectedSegment] >= 2;

    let heightDiff = vramWindow.frame.height - vramWindowContentView.bounds.height
    var windowFrame = vramWindow.frame
    windowFrame.origin.y += windowFrame.height
    switch segmentedControl.selectedSegment {
    case 0:
      windowFrame.size.height = 384 + heightDiff + 48
    case 1, 2:
      windowFrame.size.height = 512 + heightDiff + 48
    case 3:
      windowFrame.size.height = 20 * 16 + heightDiff + 24
    default:
      break
    }
    windowFrame.origin.y -= windowFrame.height
    vramWindow.setFrame(windowFrame, display: true, animate: true)
  }

  @IBAction func toggleTilesetGrid(_ sender: Any?) {
    guard let button = sender as? NSButton else {
      return
    }
    if (button.state.rawValue != 0) {
      tilesetImageView?.horizontalGrids = [
        GBImageViewGridConfiguration(color: .init(red: 0, green: 0, blue: 0, alpha: 0.25), size: 8)!,
        GBImageViewGridConfiguration(color: .init(red: 0, green: 0, blue: 0, alpha: 0.5), size: 128)!,
      ]
      tilesetImageView?.verticalGrids = [
        GBImageViewGridConfiguration(color: .init(red: 0, green: 0, blue: 0, alpha: 0.25), size: 8)!,
        GBImageViewGridConfiguration(color: .init(red: 0, green: 0, blue: 0, alpha: 0.5), size: 64)!,
      ]
      //      self.tilemapImageView.horizontalGrids = @[
      //      [[GBImageViewGridConfiguration alloc] initWithColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.25] size:8],
      //      ];
      //      self.tilemapImageView.verticalGrids = @[
      //      [[GBImageViewGridConfiguration alloc] initWithColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.25] size:8],
      //      ];
    } else {
      tilesetImageView?.horizontalGrids = nil
      tilesetImageView?.verticalGrids = nil
      //      tilemapImageView?.horizontalGrids = nil
      //      tilemapImageView?.verticalGrids = nil
    }
  }

  @IBAction func toggleScrollingDisplay(_ sender: Any?) {
    guard let button = sender as? NSButton else {
      return
    }
    tilemapImageView?.displayScrollRect = button.state.rawValue != 0
  }

  @IBAction func reloadVRAMData(_ sender: Any?) {
    guard let vramWindow = window,
          let vramTabView = vramTabView,
          let tilesetPaletteButton = tilesetPaletteButton,
          let tilesetImageView = tilesetImageView,
          let tilemapPaletteButton = tilemapPaletteButton,
          let tilemapImageView = tilemapImageView,
          let tilemapMapButton = tilemapMapButton,
          let tilemapSetButton = tilemapSetButton else {
      return
    }
    guard vramWindow.isVisible,
          let selectedTabViewItem = vramTabView.selectedTabViewItem else {
      return
    }
    switch vramTabView.tabViewItems.firstIndex(of: selectedTabViewItem) {
    case 0:  // Tileset
      let paletteType: GBPaletteType
      let paletteMenuIndex: UInt = UInt(tilesetPaletteButton.indexOfSelectedItem)
      if paletteMenuIndex > 0 {
        paletteType = paletteMenuIndex > 8 ? .OAM : .background
      } else {
        paletteType = .none
      }
      tilesetImageView.image = project.sameboy.drawTileset(withPaletteType: paletteType, menuIndex: paletteMenuIndex)
      tilesetImageView.layer?.magnificationFilter = .nearest

    case 1:  // Tilemap
      let paletteType: GBPaletteType
      let paletteMenuIndex: UInt8 = UInt8(tilemapPaletteButton.indexOfSelectedItem)
      if paletteMenuIndex > 1 {
        paletteType = paletteMenuIndex > 9 ? .OAM : .background
      } else if paletteMenuIndex == 1 {
        paletteType = .auto
      } else {
        paletteType = .none
      }
      tilemapImageView.scrollRect = NSRect(x: CGFloat(project.sameboy.scx),
                                           y: CGFloat(project.sameboy.scy),
                                           width: 160, height: 144)
      tilemapImageView.image = project.sameboy.drawTilemap(
        withPaletteType: paletteType,
        paletteIndex: paletteMenuIndex,
        mapType: GBMapType(rawValue: tilemapMapButton.indexOfSelectedItem),
        tilesetType: GBTilesetType(rawValue: tilemapSetButton.indexOfSelectedItem)
      )
      tilemapImageView.layer?.magnificationFilter = .nearest

    case 2:  // OAM
      oamInfo.withUnsafeMutableBufferPointer { buffer in
        oamCount = project.sameboy.getOAMInfo(buffer.baseAddress!, spriteHeight:&oamHeight)
      }
      guard let spritesTableView = spritesTableView else {
        return
      }
      DispatchQueue.main.async {
        self.oamUpdating = true
        spritesTableView.reloadData()
        self.oamUpdating = false
      }

    default:
      break
    }
    //        case 3:
    //        /* Palettes */
    //        {
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                [self.paletteTableView reloadData];
    //            });
    //        }
    //        break;
    //    }
  }
}

extension VRAMWindowController: EmulationObservers {
  func emulationDidAdvance() {
    if window!.isVisible {
      self.reloadVRAMData(nil)
    }
  }

  func emulationDidStart() {
  }

  func emulationDidStop() {
  }
}

extension VRAMWindowController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    switch tableView {
    case paletteTableView:
      return 16
    case spritesTableView:
      return Int(oamCount)
    default:
      return 0
    }
  }

  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    guard let tableColumn = tableColumn,
          let columnIndex = tableView.tableColumns.firstIndex(of: tableColumn) else {
      return nil
    }
    switch tableView {
    case paletteTableView:
      if columnIndex == 0 {
        return "\(row >= 8 ? "Object" : "Background") \(row & 7)"
      }
      var size: Int = 0
      let paletteData = project.sameboy.getDirectAccess(row >= 8 ? .OBP : .BGP, size: &size, bank: nil)!
      let bytes = paletteData.bindMemory(to: UInt8.self, capacity: size)
      let index = columnIndex - 1 + (row & 7) * 4
      return UInt16(truncatingIfNeeded: bytes[(index << 1) + 1] << 8) | UInt16(truncatingIfNeeded: bytes[index << 1])

    case spritesTableView:
      switch columnIndex {
      case 0:
        // C arrays are bridged as tuples in Swift, so we need to recast the tuple back to a contiguous byte buffer
        let imageData = withUnsafeMutableBytes(of: &oamInfo[row].image.0) { pointer -> Data in
          return Data(bytesNoCopy: pointer.baseAddress!, count: 64 * 4 * 2, deallocator: .none)
        }
        return SameboyEmulator.image(from: imageData, width: 8, height: UInt(truncatingIfNeeded: oamHeight), scale: 16 / Double(oamHeight))
      case 1: return oamInfo[row].x &- 8
      case 2: return oamInfo[row].y &- 16
      case 3: return "$" + oamInfo[row].tile.hexString
      case 4: return "$" + (LR35902.Address(0x8000) + LR35902.Address(truncatingIfNeeded: oamInfo[row].tile) * 0x10).hexString
      case 5: return "$" + oamInfo[row].oam_addr.hexString
      case 6: return (
        ((oamInfo[row].flags & 0x80) != 0 ? "P" : "-")
          + ((oamInfo[row].flags & 0x40) != 0 ? "Y" : "-")
          + ((oamInfo[row].flags & 0x20) != 0 ? "X" : "-")
          + ((oamInfo[row].flags & 0x08) != 0 ? "1" : "0")
          + "\(oamInfo[row].flags & 0x07)"
      )
      case 7: return oamInfo[row].obscured_by_line_limit ? "Dropped: Too many sprites in line" : ""
      default:
        fatalError()
      }

    default:
      fatalError()
    }
    return nil
  }

  func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    return tableView == spritesTableView
  }

  func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
    return false
  }
}

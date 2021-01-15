import Foundation

import Windfish

extension ProjectDocument {

  @IBAction func vramTabChanged(_ sender: Any?) {
    guard let segmentedControl = sender as? NSSegmentedControl else {
      return
    }
    guard let vramWindow = vramWindow,
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
    guard let vramWindow = vramWindow,
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
      let paletteType: GB_palette_type_t
      let paletteMenuIndex: UInt = UInt(tilesetPaletteButton.indexOfSelectedItem)
      if paletteMenuIndex > 0 {
        paletteType = paletteMenuIndex > 8 ? GB_PALETTE_OAM : GB_PALETTE_BACKGROUND
      } else {
        paletteType = GB_PALETTE_NONE
      }
      tilesetImageView.image = sameboy.drawTileset(withPaletteType: paletteType, menuIndex: paletteMenuIndex)
      tilesetImageView.layer?.magnificationFilter = .nearest

    case 1:  // Tilemap
      let paletteType: GB_palette_type_t
      let paletteMenuIndex: UInt8 = UInt8(tilemapPaletteButton.indexOfSelectedItem)
      if paletteMenuIndex > 1 {
        paletteType = paletteMenuIndex > 9 ? GB_PALETTE_OAM : GB_PALETTE_BACKGROUND
      } else if paletteMenuIndex == 1 {
        paletteType = GB_PALETTE_AUTO
      } else {
        paletteType = GB_PALETTE_NONE
      }
      tilemapImageView.scrollRect = NSRect(x: CGFloat(sameboy.readMemory(0xFF00 | UInt16(truncatingIfNeeded: GB_IO_SCX))),
                                           y: CGFloat(sameboy.readMemory(0xFF00 | UInt16(truncatingIfNeeded: GB_IO_SCY))),
                                           width: 160, height: 144)
      tilemapImageView.image = sameboy.drawTilemap(withPaletteType: paletteType,
                                                   paletteIndex: paletteMenuIndex,
                                                   mapType: GB_map_type_t(rawValue: UInt32(tilemapMapButton.indexOfSelectedItem)),
                                                   tilesetType: GB_tileset_type_t(rawValue: UInt32(tilemapSetButton.indexOfSelectedItem)))
      tilemapImageView.layer?.magnificationFilter = .nearest

    case 2:  // OAM
      oamInfo.withUnsafeMutableBufferPointer { buffer in
        oamCount = sameboy.getOAMInfo(buffer.baseAddress!, spriteHeight:&oamHeight)
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

extension ProjectDocument: NSTableViewDelegate {

}

extension ProjectDocument: NSTableViewDataSource {

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
      let paletteData = sameboy.getDirectAccess(row >= 8 ? GB_DIRECT_ACCESS_OBP : GB_DIRECT_ACCESS_BGP, size: nil, bank: nil)
      return withUnsafeBytes(of: paletteData) { buffer in
        let index = columnIndex - 1 + (row & 7) * 4
        return (buffer[(index << 1) + 1] << 8) | buffer[(index << 1)]
      }

    case spritesTableView:
      switch columnIndex {
      case 0:
        let imageData = withUnsafeMutableBytes(of: &oamInfo[row].image.0) { pointer -> Data in
          return Data(bytesNoCopy: pointer.baseAddress!, count: 64 * 4 * 2, deallocator: .none)
        }
        return Emulator.image(from: imageData, width: 8, height: UInt(truncatingIfNeeded: oamHeight), scale: 16 / Double(oamHeight))
      case 1: return oamInfo[row].x - 8
      case 2: return oamInfo[row].y - 16
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

import Foundation

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

  @IBAction func reloadVRAMData(_ sender: Any?) {
    guard let vramWindow = vramWindow,
          let vramTabView = vramTabView,
          let tilesetPaletteButton = tilesetPaletteButton,
          let tilesetImageView = tilesetImageView else {
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
    default:
      break
    }
//        case 1:
//        /* Tilemap */
//        {
//            GB_palette_type_t palette_type = GB_PALETTE_NONE;
//            NSUInteger palette_menu_index = self.tilemapPaletteButton.indexOfSelectedItem;
//            if (palette_menu_index > 1) {
//                palette_type = palette_menu_index > 9? GB_PALETTE_OAM : GB_PALETTE_BACKGROUND;
//            }
//            else if (palette_menu_index == 1) {
//                palette_type = GB_PALETTE_AUTO;
//            }
//
//            self.tilemapImageView.scrollRect = NSMakeRect([_emulator readMemory:0xFF00 | GB_IO_SCX],
//                                                          [_emulator readMemory:0xFF00 | GB_IO_SCY],
//                                                          160, 144);
//            self.tilemapImageView.image =
//                [_emulator drawTilemapWithPaletteType:palette_type
//                                         paletteIndex:palette_menu_index
//                                              mapType:(GB_map_type_t) self.tilemapMapButton.indexOfSelectedItem
//                                          tilesetType:(GB_tileset_type_t) self.TilemapSetButton.indexOfSelectedItem];
//            self.tilemapImageView.layer.magnificationFilter = kCAFilterNearest;
//        }
//        break;
//
//        case 2:
//        /* OAM */
//        {
//            oamCount = [_emulator getOAMInfo:oamInfo spriteHeight:&oamHeight];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (!oamUpdating) {
//                    oamUpdating = true;
//                    [self.spritesTableView reloadData];
//                    oamUpdating = false;
//                }
//            });
//        }
//        break;
//
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

//
//  URL+LocalizedName.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation

extension URL {
  // Returns the human-visible localized name.
  var localizedName: String {
    var localizedName = ""
    if let fileNameResource = try? resourceValues(forKeys: [.localizedNameKey]) {
      localizedName = fileNameResource.localizedName!
    } else {
      // Failed to get the localized name, use it's last path component as the name.
      localizedName = lastPathComponent
    }
    return localizedName
  }
}

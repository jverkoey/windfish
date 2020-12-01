//
//  Document.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import UIKit

class ProjectDocument: UIDocument {

  override func contents(forType typeName: String) throws -> Any {
    // Encode your document with an instance of NSData or NSFileWrapper
    return Data()
  }

  override func load(fromContents contents: Any, ofType typeName: String?) throws {
    // Load your document from contents
  }
}



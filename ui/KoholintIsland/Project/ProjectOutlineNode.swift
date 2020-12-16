//
//  ProjectOutlineNode.swiftui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation

class ProjectOutlineNode: NSObject {
  enum NodeType: Int, Codable {
    case container
    case document
    case unknown
  }

  var type: NodeType = .unknown
  var title: String = ""
  var identifier: String = ""
  var url: URL?
  @objc dynamic var children = [ProjectOutlineNode]()
}

extension ProjectOutlineNode {

  @objc var count: Int {
    children.count
  }

  @objc dynamic var isLeaf: Bool {
    return type == .document
  }
}


import Foundation

extension NSImage {
  /** A backwards compatible API for loading SFSymbols on macOS 11 or a named image on macOS 10. */
  public convenience init?(systemSymbolNameOrImageName symbolName: String, accessibilityDescription description: String?) {
    if #available(OSX 11.0, *) {
      self.init(systemSymbolName: symbolName, accessibilityDescription: nil)!
    } else {
    let nsString: NSString = NSString(string: description ?? symbolName)
      self.init(size: NSSize(width: 32, height: 32), flipped: false) { (rect: NSRect) -> Bool in
        NSColor.white.set()
        rect.fill()
        nsString.draw(at: .zero, withAttributes: [.foregroundColor: NSColor.black])
        return true
      }
    }
  }
}

protocol ViewOrLayoutGuide {
  var leadingAnchor: NSLayoutXAxisAnchor { get }
  var trailingAnchor: NSLayoutXAxisAnchor { get }
  var leftAnchor: NSLayoutXAxisAnchor { get }
  var rightAnchor: NSLayoutXAxisAnchor { get }
  var topAnchor: NSLayoutYAxisAnchor { get }
  var bottomAnchor: NSLayoutYAxisAnchor { get }
  var widthAnchor: NSLayoutDimension { get }
  var heightAnchor: NSLayoutDimension { get }
  var centerXAnchor: NSLayoutXAxisAnchor { get }
  var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension NSView: ViewOrLayoutGuide {
}

extension NSLayoutGuide: ViewOrLayoutGuide {
}

private let defaultSystemSpacing: CGFloat = 8

extension NSLayoutXAxisAnchor {
  open func constraint(equalToSystemOrDefaultSpacingAfter anchor: NSLayoutXAxisAnchor, multiplier: CGFloat) -> NSLayoutConstraint {
    if #available(OSX 11.0, *) {
      return constraint(equalToSystemSpacingAfter: anchor, multiplier: multiplier)
    } else {
      return constraint(equalTo: anchor, constant: defaultSystemSpacing * multiplier)
    }
  }
}


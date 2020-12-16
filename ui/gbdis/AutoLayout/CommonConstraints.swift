//
//  CommonConstraints.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Cocoa

func constraints(for contentView: NSView, filling containerView: NSView) -> [NSLayoutConstraint] {
  return [
    contentView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
    contentView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
    contentView.topAnchor.constraint(equalTo: containerView.topAnchor),
    contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
  ]
}

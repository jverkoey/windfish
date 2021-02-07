import Foundation
import Cocoa

import LR35902
import RGBDS
import Windfish

extension RGBDS.Statement {
  func attributedString(attributes: WINDStringAttributes,
                        opcodeAttributes: WINDStringAttributes,
                        operandAttributes: WINDStringAttributes,
                        regionLookup: [String: Region]) -> NSAttributedString {
    let string: NSMutableAttributedString = NSMutableAttributedString(string: formattedString)
    attributes.add(to: string, at: NSMakeRange(0, formattedString.count))
    opcodeAttributes.add(to: string, at: opcodeRange)
    if let spec: LR35902.Instruction.Spec = context as? LR35902.Instruction.Spec,
       let documentation: String = opcodeDocumentation[spec] {
      string.wind_addAttribute(.toolTip, value: documentation, range: opcodeRange)
    }
    for index in 0..<operands.count {
      let operand: String = operands[index]
      let range: NSRange = operandRanges[index]
      operandAttributes.add(to: string, at: range)
      if regionLookup[operand] != nil {
        string.wind_addAttribute(.link, value: "windfish://jumpto/\(operand)", range: range)
        string.wind_addAttribute(.toolTip, value: "Jump to \(operand)", range: range)
      }
    }
    return string
  }
}

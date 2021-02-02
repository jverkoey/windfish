import Foundation
import Cocoa

import RGBDS
import Windfish

extension RGBDS.Statement {
  func attributedString(attributes: WINDStringAttributes,
                        opcodeAttributes: WINDStringAttributes,
                        operandAttributes: WINDStringAttributes,
                        regionLookup: [String: Region],
                        scope: String?) -> NSAttributedString {
    let string: NSMutableAttributedString = NSMutableAttributedString(string: formattedString)
    string.beginEditing()
    opcodeAttributes.add(to: string, at: opcodeRange)
    if let spec: LR35902.Instruction.Spec = context as? LR35902.Instruction.Spec,
       let documentation: String = opcodeDocumentation[spec] {
      string.addAttribute(.toolTip, value: documentation, range: opcodeRange)
    }
    for element: (operand: String, range: NSRange) in zip(operands, operandRanges) {
      operandAttributes.add(to: string, at: element.range)
      if regionLookup[element.operand] != nil {
        string.addAttribute(.link, value: "windfish://jumpto/\(element.operand)", range: element.range)
        string.addAttribute(.toolTip, value: "Jump to \(element.operand)", range: element.range)
      }
    }
    string.endEditing()
    return string
  }
}

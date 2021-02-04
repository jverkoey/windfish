import Foundation

import os.log

extension Disassembler {
  public func willStart() {
    let oslog = OSLog(subsystem: "com.featherless.windfish", category: "PointsOfInterest")
    let signpostID = OSSignpostID(log: oslog)
    os_signpost(.begin, log: oslog, name: "Disassembler", signpostID: signpostID, "%{public}s", "willStart")

    lastBankRouter = BankRouter(numberOfBanks: configuration.numberOfBanks, context: configuration)

    prepareScriptContext()

    // Extract any scripted events.
    let disassemblyWillStarts = configuration.allScripts().values.filter { $0.disassemblyWillStart != nil }
    guard !disassemblyWillStarts.isEmpty else {
      return  // Nothing to do here.
    }

    for script in disassemblyWillStarts {
      script.disassemblyWillStart?.call(withArguments: [])
    }
    os_signpost(.end, log: oslog, name: "Disassembler", signpostID: signpostID, "%{public}s", "willStart")
  }
}

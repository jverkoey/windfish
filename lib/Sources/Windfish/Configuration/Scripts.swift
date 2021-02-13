import Foundation

#if os(macOS)
import JavaScriptCore
#endif

extension Disassembler.MutableConfiguration {
  final class Script {
    init(source: String) {
      self.source = source

#if os(macOS)
      let context = JSContext()!
      context.exceptionHandler = { context, exception in
        guard let exception = exception else {
          return
        }
        // TODO: Feed this output to a log.
        print(exception)
      }
      context.evaluateScript(source)
      self.context = context
      if let linearSweepWillStart = context.objectForKeyedSubscript("linearSweepWillStart"), !linearSweepWillStart.isUndefined {
        self.linearSweepWillStart = linearSweepWillStart
      } else {
        self.linearSweepWillStart = nil
      }
      if let linearSweepDidStep = context.objectForKeyedSubscript("linearSweepDidStep"), !linearSweepDidStep.isUndefined {
        self.linearSweepDidStep = linearSweepDidStep
      } else {
        self.linearSweepDidStep = nil
      }
      if let disassemblyWillStart = context.objectForKeyedSubscript("disassemblyWillStart"), !disassemblyWillStart.isUndefined {
        self.disassemblyWillStart = disassemblyWillStart
      } else {
        self.disassemblyWillStart = nil
      }
#endif
    }
    let source: String

    public func copy() -> Script {
      return Script(source: source)
    }

#if os(macOS)
    let context: JSContext
    let linearSweepWillStart: JSValue?
    let linearSweepDidStep: JSValue?
    let disassemblyWillStart: JSValue?
#endif
  }

  func allScripts() -> [String: Script] {
    return scripts
  }

  public func registerScript(named name: String, source: String) {
    scripts[name] = Script(source: source)
  }
}

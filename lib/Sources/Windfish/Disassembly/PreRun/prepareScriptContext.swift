import Foundation

extension Disassembler {
  func prepareScriptContext() {
    let getROMData: @convention(block) (Int, Int, Int) -> [UInt8] = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return []
      }
      let startLocation = Cartridge.Location(address: startAddress, bank: bank)
      let endLocation = Cartridge.Location(address: endAddress, bank: bank)
      return [UInt8](self.cartridgeData[startLocation.index..<endLocation.index])
    }
    let registerText: @convention(block) (Int, Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress, lineLength in
      guard let self = self else {
        return
      }
      self.mutableConfiguration.registerText(
        at: Cartridge.Location(address: startAddress, bank: bank)..<Cartridge.Location(address: endAddress, bank: bank),
        lineLength: lineLength
      )
    }
    let registerData: @convention(block) (Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return
      }
      self.mutableConfiguration.registerData(
        at: Cartridge.Location(address: startAddress, bank: bank)..<Cartridge.Location(address: endAddress, bank: bank)
      )
    }
    let registerJumpTable: @convention(block) (Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return
      }
      self.mutableConfiguration.registerData(
        at: Cartridge.Location(address: startAddress, bank: bank)..<Cartridge.Location(address: endAddress, bank: bank),
        format: .jumpTable
      )
    }
    let registerTransferOfControl: @convention(block) (Int, Int, Int, Int, Int) -> Void = { [weak self] toBank, toAddress, fromBank, fromAddress, opcode in
      guard let self = self else {
        return
      }
      self.registerTransferOfControl(
        to: Cartridge.Location(address: toAddress, bank: toBank),
        from: Cartridge.Location(address: fromAddress, bank: fromBank),
        spec: LR35902.InstructionSet.table[opcode]
      )
    }
    let registerFunction: @convention(block) (Int, Int, String) -> Void = { [weak self] bank, address, name in
      guard let self = self else {
        return
      }
      self.mutableConfiguration.registerFunction(startingAt: Cartridge.Location(address: address, bank: bank), named: name)
    }
    let registerBankChange: @convention(block) (Int, Int, Int) -> Void = { [weak self] _desiredBank, address, bank in
      guard let self = self else {
        return
      }
      let desiredBank = Cartridge.Bank(truncatingIfNeeded: _desiredBank)
      let location = Cartridge.Location(address: LR35902.Address(truncatingIfNeeded: address),
                                        bank: Cartridge.Bank(truncatingIfNeeded: bank))
      self.registerBankChange(to: max(1, desiredBank), at: location)
    }
    let hex16: @convention(block) (Int) -> String = { value in
      return UInt16(truncatingIfNeeded: value).hexString
    }
    let hex8: @convention(block) (Int) -> String = { value in
      return UInt8(truncatingIfNeeded: value).hexString
    }
    let log: @convention(block) (Int) -> Void = { value in
      print(value.hexString)
    }

    let scripts: [String: Configuration.Script] = configuration.allScripts()
    for script in scripts.values {
      script.context.setObject(getROMData, forKeyedSubscript: "getROMData" as NSString)
      script.context.setObject(registerText, forKeyedSubscript: "registerText" as NSString)
      script.context.setObject(registerData, forKeyedSubscript: "registerData" as NSString)
      script.context.setObject(registerJumpTable, forKeyedSubscript: "registerJumpTable" as NSString)
      script.context.setObject(registerTransferOfControl, forKeyedSubscript: "registerTransferOfControl" as NSString)
      script.context.setObject(registerFunction, forKeyedSubscript: "registerFunction" as NSString)
      script.context.setObject(registerBankChange, forKeyedSubscript: "registerBankChange" as NSString)
      script.context.setObject(hex16, forKeyedSubscript: "hex16" as NSString)
      script.context.setObject(hex8, forKeyedSubscript: "hex8" as NSString)
      script.context.setObject(log, forKeyedSubscript: "log" as NSString)
    }
  }
}

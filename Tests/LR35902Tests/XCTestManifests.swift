#if !canImport(ObjectiveC)
import XCTest

extension AddressConversionTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__AddressConversionTests = [
        ("testAddressAndBankBeginningOfBank1", testAddressAndBankBeginningOfBank1),
        ("testAddressAndBankBeginningOfBank2", testAddressAndBankBeginningOfBank2),
        ("testAddressAndBankEndOfBank0", testAddressAndBankEndOfBank0),
        ("testBank0WithBank1Selected", testBank0WithBank1Selected),
        ("testBeginningOfBank1", testBeginningOfBank1),
        ("testBeginningOfBank2", testBeginningOfBank2),
        ("testEndOfBank0", testEndOfBank0),
        ("testMiddleOfBank0", testMiddleOfBank0),
        ("testUnselectedBankGivesNilCartAddressAbove0x3FFF", testUnselectedBankGivesNilCartAddressAbove0x3FFF),
        ("testZero", testZero),
    ]
}

extension LR35902InstructionTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__LR35902InstructionTests = [
        ("test_dec_b", test_dec_b),
        ("test_inc_b", test_inc_b),
        ("test_inc_bc", test_inc_bc),
        ("test_ld_bc_imm16", test_ld_bc_imm16),
        ("test_ld_bcadd_a", test_ld_bcadd_a),
        ("test_nop", test_nop),
    ]
}

extension RGBDAssembler {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__RGBDAssembler = [
        ("test_allInstructions", test_allInstructions),
        ("test_bit_2_b", test_bit_2_b),
        ("test_inc_bc", test_inc_bc),
        ("test_jr_cond", test_jr_cond),
        ("test_jr", test_jr),
        ("test_ld_a_bcaddr", test_ld_a_bcaddr),
        ("test_ld_b_imm8_0xHex", test_ld_b_imm8_0xHex),
        ("test_ld_b_imm8", test_ld_b_imm8),
        ("test_ld_bc_imm16_0xHexIsRepresentable", test_ld_bc_imm16_0xHexIsRepresentable),
        ("test_ld_bc_imm16_dollarHexIsRepresentable", test_ld_bc_imm16_dollarHexIsRepresentable),
        ("test_ld_bc_imm16_emptyNumberFails", test_ld_bc_imm16_emptyNumberFails),
        ("test_ld_bc_imm16_negativeNumberIsRepresentable", test_ld_bc_imm16_negativeNumberIsRepresentable),
        ("test_ld_bc_imm16_nop", test_ld_bc_imm16_nop),
        ("test_ld_bc_imm16_numberIsRepresentable", test_ld_bc_imm16_numberIsRepresentable),
        ("test_ld_bc_imm16_unrepresentableNumberFails", test_ld_bc_imm16_unrepresentableNumberFails),
        ("test_ld_bcAddress_a", test_ld_bcAddress_a),
        ("test_ld_ffimm8_a", test_ld_ffimm8_a),
        ("test_ld_hl_spimm8", test_ld_hl_spimm8),
        ("test_ld_imm16_a", test_ld_imm16_a),
        ("test_ld_imm16addr_sp", test_ld_imm16addr_sp),
        ("test_newline_doesNotCauseParseFailures", test_newline_doesNotCauseParseFailures),
        ("test_nop_1", test_nop_1),
        ("test_nop_2", test_nop_2),
        ("test_nop_failsWithExtraOperand", test_nop_failsWithExtraOperand),
        ("test_nop_failsWithExtraOperandAtCorrectLine", test_nop_failsWithExtraOperandAtCorrectLine),
        ("test_ret_z", test_ret_z),
        ("test_rlc_b", test_rlc_b),
        ("test_rrca", test_rrca),
        ("test_rst", test_rst),
        ("test_set_6_hladdr", test_set_6_hladdr),
        ("test_sub_imm8", test_sub_imm8),
        ("testBoo", testBoo),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AddressConversionTests.__allTests__AddressConversionTests),
        testCase(LR35902InstructionTests.__allTests__LR35902InstructionTests),
        testCase(RGBDAssembler.__allTests__RGBDAssembler),
    ]
}
#endif

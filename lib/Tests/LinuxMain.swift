import XCTest

import CPUTests
import WindfishTests

var tests = [XCTestCaseEntry]()
tests += CPUTests.__allTests()
tests += LR35902Tests.__allTests()

XCTMain(tests)

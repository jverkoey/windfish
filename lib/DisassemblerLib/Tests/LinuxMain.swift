import XCTest

import CPUTests
import LR35902Tests

var tests = [XCTestCaseEntry]()
tests += CPUTests.__allTests()
tests += LR35902Tests.__allTests()

XCTMain(tests)

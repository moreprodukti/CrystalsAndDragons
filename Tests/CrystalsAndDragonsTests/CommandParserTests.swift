@testable import Controller
@testable import Model
import XCTest

final class CommandParserTests: XCTestCase {
    func testTorchlightWithoutColorDefaultsToBright() {
        let parser = CommandParser()
        let command = parser.parse(command: "get torchlight")

        switch command {
        case let .get(itemName, color):
            XCTAssertEqual(itemName, "torchlight")
            XCTAssertEqual(color, .bright)
        default:
            XCTFail("Expected get torchlight command")
        }
    }

    func testTorchlightWithWrongColorFails() {
        let parser = CommandParser()
        let command = parser.parse(command: "get red torchlight")

        if case .parseError = command {
            return
        }
        XCTFail("Expected parseError for non-bright torchlight color")
    }

    func testAmbiguousColorFails() {
        let parser = CommandParser()
        let command = parser.parse(command: "get red blue key")

        if case .parseError = command {
            return
        }
        XCTFail("Expected parseError for ambiguous colors")
    }

    func testOpenParsesWithColor() {
        let parser = CommandParser()
        let command = parser.parse(command: "open green chest")

        switch command {
        case let .open(color):
            XCTAssertEqual(color, .green)
        default:
            XCTFail("Expected open command with green color")
        }
    }

    func testOpenParsesForAllChestColors() {
        let parser = CommandParser()
        let cases: [(String, Color)] = [
            ("open red chest", .red),
            ("open green chest", .green),
            ("open blue chest", .blue),
            ("open yellow chest", .yellow),
        ]

        for (input, expectedColor) in cases {
            let command = parser.parse(command: input)
            switch command {
            case let .open(color):
                XCTAssertEqual(color, expectedColor, "Input: \(input)")
            default:
                XCTFail("Expected open command for input: \(input)")
            }
        }
    }

    func testOpenFailsWithoutColor() {
        let parser = CommandParser()
        let command = parser.parse(command: "open chest")

        if case .parseError = command {
            return
        }
        XCTFail("Expected parseError when chest color is missing")
    }

    func testOpenFailsWithAmbiguousColors() {
        let parser = CommandParser()
        let command = parser.parse(command: "open red blue chest")

        if case .parseError = command {
            return
        }
        XCTFail("Expected parseError for ambiguous open command colors")
    }

    func testGetKeyParsesForAllColors() {
        let parser = CommandParser()
        let cases: [(String, Color)] = [
            ("get red key", .red),
            ("get green key", .green),
            ("get blue key", .blue),
            ("get yellow key", .yellow),
        ]

        for (input, expectedColor) in cases {
            let command = parser.parse(command: input)
            switch command {
            case let .get(itemName, color):
                XCTAssertEqual(itemName, "key", "Input: \(input)")
                XCTAssertEqual(color, expectedColor, "Input: \(input)")
            default:
                XCTFail("Expected get key command for input: \(input)")
            }
        }
    }

    func testDropKeyParsesForAllColors() {
        let parser = CommandParser()
        let cases: [(String, Color)] = [
            ("drop red key", .red),
            ("drop green key", .green),
            ("drop blue key", .blue),
            ("drop yellow key", .yellow),
        ]

        for (input, expectedColor) in cases {
            let command = parser.parse(command: input)
            switch command {
            case let .drop(itemName, color):
                XCTAssertEqual(itemName, "key", "Input: \(input)")
                XCTAssertEqual(color, expectedColor, "Input: \(input)")
            default:
                XCTFail("Expected drop key command for input: \(input)")
            }
        }
    }
}

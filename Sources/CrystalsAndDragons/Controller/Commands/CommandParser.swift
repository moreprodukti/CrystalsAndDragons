//
//  CommandParser.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation
import Model

public struct CommandParser {
    public init() {}

    public func parse(command: String) -> Command {
        let tokens = normalizeTokens(input: command)

        if tokens.contains("get") {
            if let key = keyItem(input: tokens) {
                return .get(itemName: key.0, color: key.1)
            }

            if let meat = meatItem(input: tokens) {
                return .get(itemName: meat.0, color: meat.1)
            }

            return .parseError
        }

        if tokens.contains("drop") {
            if let key = keyItem(input: tokens) {
                return .drop(itemName: key.0, color: key.1)
            }

            if let meat = meatItem(input: tokens) {
                return .drop(itemName: meat.0, color: meat.1)
            }

            return .parseError
        }

        if tokens.contains("eat") {
            guard let meat = meatItem(input: tokens) else {
                return .parseError
            }

            return .eat(itemName: meat.0, color: meat.1)
        }

        if tokens.contains("inv") {
            return .inventory
        }

        if tokens.contains("quit") {
            return .quit
        }

        if tokens.contains("open") {
            guard let itemColor = parseColor(input: tokens) else {
                return .parseError
            }
            return .open(color: itemColor)
        }

        guard let dir = parseDirection(input: tokens) else {
            return .parseError
        }
        return .move(dir)
    }

    private func normalizeTokens(input: String) -> [String] {
        return stripANSIEscapeCodes(from: input)
            .lowercased()
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: ".", with: " ")
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
    }

    private func stripANSIEscapeCodes(from input: String) -> String {
        let pattern = #"\u{001B}\[[0-9;]*m"#
        return input.replacingOccurrences(
            of: pattern,
            with: "",
            options: .regularExpression
        )
    }

    private func parseColor(input: [String]) -> Color? {
        var itemColor: Color? = nil

        if input.contains("blue") {
            itemColor = .blue
        }

        if input.contains("red") {
            itemColor = .red
        }

        if input.contains("yellow") {
            itemColor = .yellow
        }

        if input.contains("green") {
            itemColor = .green
        }

        if input.contains("roasted") {
            itemColor = .roasted
        }
        return itemColor
    }

    private func parseDirection(input: [String]) -> Direction? {
        if input.contains("n") {
            return .N
        }
        if input.contains("s") {
            return .S
        }
        if input.contains("e") {
            return .E
        }
        if input.contains("w") {
            return .W
        }
        return nil
    }

    private func keyItem(input: [String]) -> (String, Color)? {
        guard input.contains("key") else {
            return nil
        }

        guard let itemColor = parseColor(input: input) else {
            return nil
        }
        return ("key", itemColor)
    }

    private func meatItem(input: [String]) -> (String, Color)? {
        guard input.contains("hearty"), input.contains("meat") else {
            return nil
        }

        guard let itemColor = parseColor(input: input) else {
            return nil
        }
        return ("hearty meat", itemColor)
    }
}

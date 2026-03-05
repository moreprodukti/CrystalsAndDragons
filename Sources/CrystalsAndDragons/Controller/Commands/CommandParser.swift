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
            if let gold = goldItem(input: tokens) {
                return .get(itemName: gold.0, color: gold.1)
            }

            if let key = keyItem(input: tokens) {
                return .get(itemName: key.0, color: key.1)
            }

            if let meat = meatItem(input: tokens) {
                return .get(itemName: meat.0, color: meat.1)
            }

            if let torch = torchItem(input: tokens) {
                return .get(itemName: torch.0, color: torch.1)
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

            if let torch = torchItem(input: tokens) {
                return .drop(itemName: torch.0, color: torch.1)
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

        if input.contains("bright") {
            itemColor = .bright
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

    private func torchItem(input: [String]) -> (String, Color)? {
        guard input.contains("torchlight") else {
            return nil
        }

        guard let itemColor = parseColor(input: input) else {
            return nil
        }
        return ("torchlight", itemColor)
    }

    private func goldItem(input: [String]) -> (String, Color)? {
        guard input.contains("gold") else {
            return nil
        }
        return ("gold", .gold)
    }
}

//
//  ViewMessage.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 05/03/26.
//

import Foundation

public struct ViewMessage {
    public enum TextColor {
        case red
        case green
        case blue
        case yellow
        case gold
        case roasted
    }

    public struct Segment {
        public let text: String
        public let color: TextColor?

        public init(text: String, color: TextColor? = nil) {
            self.text = text
            self.color = color
        }
    }

    public enum Kind {
        case info
        case success
        case warning
        case error
    }

    public let segments: [Segment]
    public let kind: Kind

    public init(text: String, kind: Kind) {
        self.segments = [Segment(text: text)]
        self.kind = kind
    }

    public init(segments: [Segment], kind: Kind) {
        self.segments = segments
        self.kind = kind
    }

    public var text: String {
        segments.map(\.text).joined()
    }
}

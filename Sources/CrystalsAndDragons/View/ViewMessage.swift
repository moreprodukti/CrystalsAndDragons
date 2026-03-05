//
//  ViewMessage.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 05/03/26.
//

import Foundation

public struct ViewMessage {
    public enum Kind {
        case info
        case success
        case warning
        case error
    }

    public let text: String
    public let kind: Kind

    public init(text: String, kind: Kind) {
        self.text = text
        self.kind = kind
    }
}

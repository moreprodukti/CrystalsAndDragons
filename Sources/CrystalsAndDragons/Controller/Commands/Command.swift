//
//  Command.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation
import Model

public enum Command {
    case move(Direction)
    case get(itemName: String, color: Color)
    case drop(itemName: String, color: Color)
    case eat(itemName: String, color: Color)
    case open(color: Color)
    case inventory
    case quit
    case parseError
}

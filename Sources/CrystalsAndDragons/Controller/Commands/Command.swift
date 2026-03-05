//
//  Command.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation

enum Command {
    case move(Direction)
    case get(itemName: String, color: Color)
    case drop(itemName: String, color: Color)
    case open(color: Color)
    case inventory
    case quit
}

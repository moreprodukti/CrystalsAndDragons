//
//  Player.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation

final class Player: HasItem {
    var health: Int
    var position: Position
    var items: [any Item]

    init(health: Int, position: Position, items: [Item]) {
        self.health = health
        self.position = position
        self.items = items
    }
}

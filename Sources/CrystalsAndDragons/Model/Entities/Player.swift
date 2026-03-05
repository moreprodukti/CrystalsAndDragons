//
//  Player.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation

final class Player {
    var health: Int
    var position: Position
    var gold: Int = 0

    private(set) var items: [any Item]

    init(health: Int, position: Position, items: [any Item]) {
        self.health = health
        self.position = position
        self.items = items
    }

    func hasItem(named itemName: String, color: Color) -> Bool {
        return items.contains { $0.name == itemName && $0.color == color }
    }

    func putItem(_ item: any Item) {
        items.append(item)
    }

    func dropItem(named itemName: String, color: Color) -> (any Item)? {
        guard let index = items.firstIndex(where: { $0.name == itemName && $0.color == color }) else {
            return nil
        }
        return items.remove(at: index)
    }

    func eatItem(named itemName: String, color: Color) -> (any Item)? {
        defer { health += 1 }
        guard let index = items.firstIndex(where: { $0.name == itemName && $0.color == color }) else {
            return nil
        }
        return items.remove(at: index)
    }
}

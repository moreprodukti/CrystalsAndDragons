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
    private var inventory: Inventory
    var items: [any Item] { inventory.items }

    init(health: Int, position: Position, items: [any Item]) {
        self.health = health
        self.position = position
        self.inventory = Inventory(items: items)
    }

    func hasItem(named itemName: String, color: Color) -> Bool {
        inventory.hasItem(named: itemName, color: color)
    }

    func putItem(_ item: any Item) {
        inventory.add(item)
    }

    func takeItem(named itemName: String, color: Color) -> (any Item)? {
        inventory.take(named: itemName, color: color)
    }
}

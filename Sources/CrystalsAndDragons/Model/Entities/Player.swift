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
    private(set) var inventory: Inventory

    init(health: Int, position: Position, inventory: [any Item]) {
        self.health = health
        self.position = position
        self.inventory = Inventory(items: inventory)
    }

    func hasItem(named itemName: String, color: Color) -> Bool {
        return inventory.hasItem(named: itemName, color: color)
    }

    func putItem(_ item: any Item) {
        inventory.add(item)
    }

    func dropItem(named itemName: String, color: Color) -> (any Item)? {
        return inventory.remove(named: itemName, color: color)
    }
}

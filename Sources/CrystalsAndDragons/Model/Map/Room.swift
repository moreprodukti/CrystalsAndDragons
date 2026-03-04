//
//  Room.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

final class Room {
    private var inventory: Inventory
    var items: [any Item] { inventory.items }
    let doors: Set<Direction>
    let position: Position

    init(items: [any Item], doors: Set<Direction>, position: Position) {
        self.inventory = Inventory(items: items)
        self.doors = doors
        self.position = position
    }

    func hasItem(named itemName: String, color: Color) -> Bool {
        return inventory.hasItem(named: itemName, color: color)
    }

    func putItem(_ item: any Item) {
        inventory.add(item)
    }

    func takeItem(named itemName: String, color: Color) -> (any Item)? {
        return inventory.take(named: itemName, color: color)
    }
}

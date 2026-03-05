//
//  Room.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

final class Room {
    private(set) var items: Inventory
    let doors: Set<Direction>
    let position: Position

    init(items: [any Item], doors: Set<Direction>, position: Position) {
        self.items = Inventory(items: items)
        self.doors = doors
        self.position = position
    }

    func hasItem(named itemName: String, color: Color) -> Bool {
        return items.hasItem(named: itemName, color: color)
    }

    func putItem(_ item: any Item) {
        items.add(item)
    }

    func takeItem(named itemName: String, color: Color) -> (any Item)? {
        return items.remove(named: itemName, color: color)
    }
}

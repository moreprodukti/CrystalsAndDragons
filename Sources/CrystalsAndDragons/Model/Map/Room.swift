//
//  Room.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

final class Room {
    private(set) var items: [any Item]
    let doors: Set<Direction>
    let position: Position

    init(items: [any Item], doors: Set<Direction>, position: Position) {
        self.items = items
        self.doors = doors
        self.position = position
    }

    func hasItem(named itemName: String, color: Color) -> Bool {
        return items.contains { $0.name == itemName && $0.color == color }
    }

    func putItem(_ item: any Item) {
        items.append(item)
    }

    func takeItem(named itemName: String, color: Color) -> (any Item)? {
        guard let index = items.firstIndex(where: { $0.name == itemName && $0.color == color }) else {
            return nil
        }
        return items.remove(at: index)
    }
}

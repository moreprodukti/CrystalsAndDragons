//
//  Room.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

final class Room {
    private(set) var items: [any Item]
    private(set) var gold: Int
    let doors: Set<Direction>
    let position: Position
    let isDark: Bool

    init(items: [any Item], doors: Set<Direction>, position: Position, gold: Int, isDark: Bool) {
        self.items = items
        self.doors = doors
        self.position = position
        self.gold = gold
        self.isDark = isDark
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

    func takeGold() -> Int {
        let coins = gold
        gold = 0
        return coins
    }
}

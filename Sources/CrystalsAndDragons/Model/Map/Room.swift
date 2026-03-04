//
//  Room.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

final class Room: HasItem {
    var items: [Item]
    let doors: Set<Direction>
    let position: Position

    init(items: [Item], doors: Set<Direction>, position: Position) {
        self.items = items
        self.doors = doors
        self.position = position
    }
}

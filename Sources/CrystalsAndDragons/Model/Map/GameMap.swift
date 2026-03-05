//
//  GameMap.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation

final class GameMap {
    let rooms: [[Room]]

    init(rooms: [[Room]]) {
        self.rooms = rooms
    }

    func getRoomItems(_ position: Position) -> [any Item] {
        return rooms[position.y][position.x].items
    }

    func getRoomDirections(_ position: Position) -> Set<Direction> {
        return rooms[position.y][position.x].doors
    }

    func isValid(position: Position) -> Bool {
        guard position.y >= 0, position.y < rooms.count else {
            return false
        }
        guard position.x >= 0, position.x < rooms[position.y].count else {
            return false
        }
        return true
    }
}

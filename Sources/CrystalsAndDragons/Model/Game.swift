//
//  Game.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation

public final class Game {
    private var player: Player
    private let gameMap: GameMap

    var state: GameState {
        if player.health <= 0 {
            return .lost
        }
        if player.hasItem(named: "The Holy Grail", color: .gold) {
            return .win
        }
        return .playing
    }

    init(player: Player, gameMap: GameMap) {
        self.player = player
        self.gameMap = gameMap
    }

    public func movePlayer(direction: Direction) -> Result<GameEvent, GameError> {
        let currentPosition = player.position

        guard gameMap.rooms[currentPosition.y][currentPosition.x].doors.contains(direction) else {
            return .failure(.blockedMove)
        }

        let targetPosition: Position
        switch direction {
        case .N: targetPosition = Position(x: currentPosition.x, y: currentPosition.y - 1)

        case .S: targetPosition = Position(x: currentPosition.x, y: currentPosition.y + 1)

        case .E: targetPosition = Position(x: currentPosition.x + 1, y: currentPosition.y)

        case .W: targetPosition = Position(x: currentPosition.x - 1, y: currentPosition.y)
        }

        guard gameMap.isValid(position: targetPosition) else {
            return .failure(.blockedMove)
        }

        player.position = targetPosition
        player.health -= 1
        return .success(.moved(direction))
    }

    public func getItem(named itemName: String, color: Color) -> Result<GameEvent, GameError> {
        let room = gameMap.rooms[player.position.y][player.position.x]

        guard room.hasItem(named: itemName, color: color) else {
            return .failure(.noSuchItemHere)
        }

        guard let foundItem = room.takeItem(named: itemName, color: color) else {
            return .failure(.noSuchItemHere)
        }

        player.putItem(foundItem)

        return .success(.itemPicked(name: itemName, color: color))
    }

    public func dropItem(named itemName: String, color: Color) -> Result<GameEvent, GameError> {
        let room = gameMap.rooms[player.position.y][player.position.x]

        guard player.hasItem(named: itemName, color: color) else {
            return .failure(.noSuchItemInInventory)
        }

        guard let droppedItem = player.dropItem(named: itemName, color: color) else {
            return .failure(.noSuchItemInInventory)
        }

        room.putItem(droppedItem)

        return .success(.itemDropped(name: itemName, color: color))
    }

    public func takeItemFromChest() -> Result<GameEvent, GameError> {
        let room = gameMap.rooms[player.position.y][player.position.x]

        guard let chest = room.items.compactMap({ $0 as? Chest }).first else {
            return .failure(.noChestHere)
        }

        if chest.isOpen {
            return .success(.chestOpened(item: chest.takeItemFromChest()))
        }

        guard player.hasItem(named: "key", color: chest.color) else {
            return .failure(.noRightKey)
        }

        chest.open()
        let chestItem = chest.takeItemFromChest()
        if let chestItem {
            player.putItem(chestItem)
        }
        return .success(.chestOpened(item: chestItem))
    }

    public func eatItem(named itemName: String, color: Color) -> Result<GameEvent, GameError> {
        guard player.hasItem(named: itemName, color: color) else {
            return .failure(.noSuchItemInInventory)
        }

        guard let eatedItem = player.eatItem(named: itemName, color: color) else {
            return .failure(.noSuchItemInInventory)
        }

        return .success(.itemEaten(name: eatedItem.name, color: eatedItem.color))
    }

    public func openInventory() -> [any Item] {
        return player.items
    }

    public func getPlayerHP() -> Int {
        return player.health
    }

    public func getPlayerPosition() -> Position {
        return player.position
    }

    public func getRoomItems() -> [any Item] {
        return gameMap.getRoomItems(player.position)
    }

    public func getRoomDirections() -> Set<Direction> {
        return gameMap.getRoomDirections(player.position)
    }

    public func checkGameStatus() -> GameState { return state }
}

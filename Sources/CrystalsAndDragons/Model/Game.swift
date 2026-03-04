//
//  Game.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation

final class Game {
    private(set) var state: GameState = .playing
    private(set) var player: Player
    private let gameMap: GameMap

    init(player: Player, gameMap: GameMap) {
        self.player = player
        self.gameMap = gameMap
    }

    func movePlayer(direction: Direction) -> String {
        guard gameMap.rooms[player.position.y][player.position.x].doors.contains(direction) else {
            return "You can't go that way"
        }

        switch direction {
        case .N:
            player.position = Position(x: player.position.x, y: player.position.y + 1)

        case .S:
            player.position = Position(x: player.position.x, y: player.position.y - 1)

        case .E:
            player.position = Position(x: player.position.x + 1, y: player.position.y)

        case .W:
            player.position = Position(x: player.position.x - 1, y: player.position.y)
        }

        return "You moved \(direction)"
    }

    func getItem(named itemName: String, color: Color) -> String {
        var room = gameMap.rooms[player.position.y][player.position.x]

        guard room.hasItem(named: itemName, color: color) else {
            return "There's nothing like that here"
        }

        let foundItem = room.deleteItem(named: itemName, color: color)

        player.addItem(foundItem)

        return "You picked up \(color) \(itemName)"
    }

    func dropItem(named itemName: String, color: Color) -> String {
        var room = gameMap.rooms[player.position.y][player.position.x]

        guard player.hasItem(named: itemName, color: color) else {
            return "You don't have this item!"
        }

        let droppedItem = player.deleteItem(named: itemName, color: color)

        room.addItem(droppedItem)

        return "You dropped \(color) \(itemName)"
    }

    func takeItemFromChest() -> String {
        var room = gameMap.rooms[player.position.y][player.position.x]

        for item in room.items {
            if let chest = item as? Chest {
                if !chest.isOpen && player.hasItem(named: "key", color: chest.color) {
                    chest.open()
                    guard let chestItem = chest.takeItemFromChest() else {
                        return "Empty"
                    }
                    player.addItem(chestItem)
                    return "You found \(chestItem.name) in the chest!"
                }
            }
        }
        return "No chest to open here"
    }

    func checkGameStatus() -> String? {
        updateGameState()

        switch state {
        case .win:
            return victory()
        case .lost:
            return gameOver()
        case .playing:
            return nil
        }
    }

    private func victory() -> String {
        return """

        ╔══════════════════════════════════════════════════════╗
        ║                                                      ║
        ║     ✨✨✨  VICTORY! ✨✨✨                         ║
        ║                                                      ║
        ║     You have found the Holy Grail!                   ║
        ║     The ancient prophecy is fulfilled...             ║
        ║                                                      ║
        ║     You are now the rightful ruler of the kingdom!   ║
        ║                                                      ║
        ╚══════════════════════════════════════════════════════╝

        """
    }

    private func gameOver() -> String {
        return """
            
        ╔══════════════════════════════════════════════════════╗
        ║                                                      ║
        ║            💀💀💀  GAME OVER  💀💀💀                ║
        ║                                                      ║
        ║            Your journey ends here...                 ║
        ║                                                      ║
        ╚══════════════════════════════════════════════════════╝
            
        """
    }

    private func updateGameState() {
        if player.health <= 0 {
            state = .lost
        } else if player.hasItem(named: "grail", color: .gold) {
            state = .win
        }
    }
}

//
//  GameController.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation
import Model
import View

public final class GameController {
    private let game: Game
    private let view: ConsoleView
    private let parser = CommandParser()

    public init(game: Game, view: ConsoleView) {
        self.game = game
        self.view = view
    }

    public convenience init(roomCount: Int) throws {
        let game = try GameGenerator().generate(roomCount: roomCount)
        self.init(game: game, view: ConsoleView())
    }

    public func getCommand() -> Command {
        guard let input = view.readCommand() else {
            return .parseError
        }
        return parser.parse(command: input)
    }
    
    public func runCommand(_ command: Command) -> ViewMessage {
        var commandResult: Result<GameEvent, GameError>
        
        switch command {
        case .move(let direction):
            commandResult = game.movePlayer(direction: direction)

        case .get(let itemName, let color):
            commandResult = game.getItem(named: itemName, color: color)

        case .drop(let itemName, let color):
            commandResult = game.dropItem(named: itemName, color: color)

        case .open(_):
            commandResult = game.takeItemFromChest()

        case .inventory:
            let items = game.openInventory()
            
            if items.isEmpty {
                return ViewMessage(text: "Inventory: Empty", kind: .info)
            } else {
                let itemsStr = items.map { "\($0.color) \($0.name)"}
                return ViewMessage(text: "Inventory: [\(itemsStr.joined(separator: ", "))]", kind: .info)
            }
        case .quit:
            return ViewMessage(text: "", kind: .info)

        case .parseError:
            return ViewMessage(text: "Can't parse command", kind: .error)
        }
        
        return mapToViewMessage(commandResult)
    }
    
    public func sendResponse(_ response: ViewMessage) {
        view.showMessage(response)
    }
    
    public func playerInfo() -> ViewMessage {
        return ViewMessage(text: "HP: \(game.getPlayerHP())", kind: .info)
    }
    
    public func playerPosition() -> ViewMessage {
        let position = game.getPlayerPosition()
        let directions = game.getRoomDirections()
        let directionText = directions.map(directionText).joined(separator: ", ")
        let items = game.getRoomItems().map { "\($0.color) \($0.name)" }
        let itemsText = items.joined(separator: ", ")

        return ViewMessage(
            text: "You are in the room [\(position.x), \(position.y)]. There are \(directions.count) doors: [\(directionText)]. Items in the room: [\(itemsText)]",
            kind: .info
        )
    }
    
    public func startScreen() {
        view.showStartScreen()
    }

    public func isGameFinished() -> Bool {
        switch game.checkGameStatus() {
        case .playing:
            return false
        case .win:
            view.victory()
            return true
        case .lost:
            view.gameOver()
            return true
        }
    }
    
    private func directionText(_ d: Direction) -> String {
        switch d {
        case .N: return "N"
        case .S: return "S"
        case .E: return "E"
        case .W: return "W"
        }
    }
    
    private func mapToViewMessage(_ result: Result<GameEvent, GameError>) -> ViewMessage {
        switch result {
        case let .success(event):
            
            switch event {
            case let .itemPicked(name, color):
                return ViewMessage(text: "You picked up \(color) \(name)", kind: .success)
                
            case let .itemDropped(name, color):
                return ViewMessage(text: "You dropped up \(color) \(name)", kind: .success)
                
            case let .chestOpened(item):
                if let item {
                    return ViewMessage(text: "You found \(item.name) in the chest!", kind: .success)
                }
                return ViewMessage(text: "Empty", kind: .info)
                
            case let .moved(direction):
                return ViewMessage(text: "You moved \(direction)", kind: .info)
            }
            
        case let .failure(error):
            
            switch error {
            case .blockedMove:
                return ViewMessage(text: "You can't go that way", kind: .warning)
                
            case .noChestHere:
                return ViewMessage(text: "No chest to open here", kind: .warning)
                
            case .noRightKey:
                return ViewMessage(text: "You don't have the right key", kind: .warning)
                
            case .noSuchItemHere:
                return ViewMessage(text: "There's nothing like that here", kind: .warning)
                
            case .noSuchItemInInventory:
                return ViewMessage(text: "You don't have this item!", kind: .warning)
            }
        }
    }
}

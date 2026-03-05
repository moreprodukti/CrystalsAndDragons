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
    private let parser: CommandParser
    private let generator: GameGenerator

    public init(
        game: Game,
        view: ConsoleView,
        parser: CommandParser = CommandParser(),
        generator: GameGenerator = GameGenerator()
    ) {
        self.game = game
        self.view = view
        self.parser = parser
        self.generator = generator
    }

    public convenience init(
        roomCount: Int,
        view: ConsoleView = ConsoleView(),
        parser: CommandParser = CommandParser(),
        generator: GameGenerator = GameGenerator()
    ) throws {
        let game = try generator.generate(roomCount: roomCount)
        self.init(game: game, view: view, parser: parser, generator: generator)
    }

    public static func bootstrapConsoleController(
        parser: CommandParser = CommandParser(),
        generator: GameGenerator = GameGenerator()
    ) -> GameController? {
        let view = ConsoleView()
        view.clearScreen()
        view.showRoomCountPrompt()

        guard
            let roomCount = view.readRoomCount(),
            roomCount > 0
        else {
            view.showInvalidRoomCount()
            return nil
        }

        do {
            return try GameController(
                roomCount: roomCount,
                view: view,
                parser: parser,
                generator: generator
            )
        } catch {
            view.showGenerationFailed(error)
            return nil
        }
    }

    public func runGameLoop() {
        view.showStartScreen()
        view.showMessage(playerInfo())
        view.showMessage(playerPosition())

        while true {
            let command = getCommand()
            if case .quit = command {
                break
            }

            let response = runCommand(command)
            view.showMessage(response)
            if isGameFinished() {
                break
            }
            view.showMessage(playerInfo())
            view.showMessage(playerPosition())
        }
    }

    private func getCommand() -> Command {
        view.chooseAction()
        guard let input = view.readCommand() else {
            return .parseError
        }
        return parser.parse(command: input)
    }

    private func runCommand(_ command: Command) -> ViewMessage {
        var commandResult: Result<GameEvent, GameError>

        switch command {
        case let .move(direction):
            commandResult = game.movePlayer(direction: direction)

        case let .get(itemName, color):
            if itemName == "gold" {
                commandResult = game.getGold()
            } else {
                commandResult = game.getItem(named: itemName, color: color)
            }

        case let .drop(itemName, color):
            commandResult = game.dropItem(named: itemName, color: color)

        case let .eat(itemName, color):
            commandResult = game.eatItem(named: itemName, color: color)

        case .open:
            commandResult = game.takeItemFromChest()

        case .inventory:
            let items = game.openInventory()
            let goldCoins = game.getPlayerGold()

            if items.isEmpty, goldCoins == 0 {
                return ViewMessage(text: "Inventory: []", kind: .info)
            } else {
                var segments = [ViewMessage.Segment(text: "Inventory: [")]
                var hasAny = false

                if goldCoins > 0 {
                    segments.append(
                        ViewMessage.Segment(
                            text: "gold coins: \(goldCoins)",
                            color: .gold
                        )
                    )
                    hasAny = true
                }

                if !items.isEmpty {
                    if hasAny {
                        segments.append(ViewMessage.Segment(text: ", "))
                    }
                    segments.append(contentsOf: itemSegments(for: items))
                }

                segments.append(ViewMessage.Segment(text: "]"))
                return ViewMessage(segments: segments, kind: .info)
            }

        case .quit:
            return ViewMessage(text: "", kind: .info)

        case .parseError:
            return ViewMessage(text: "Can't parse command", kind: .error)
        }

        return mapToViewMessage(commandResult)
    }

    private func playerInfo() -> ViewMessage {
        return ViewMessage(text: "HP: \(game.getPlayerHP())", kind: .info)
    }

    private func playerPosition() -> ViewMessage {
        let position = game.getPlayerPosition()
        let directions = game.getRoomDirections()
        let directionText = directions.map(directionText).joined(separator: ", ")
        let items = game.getRoomItems()
        let roomGold = game.getRoomGold()

        var segments = [
            ViewMessage.Segment(
                text: "You are in the room [\(position.x), \(position.y)]. There are \(directions.count) doors: [\(directionText)]. Items in the room: ["
            ),
        ]
        var hasAny = false
        if roomGold > 0 {
            segments.append(
                ViewMessage.Segment(
                    text: "gold coins: \(roomGold)",
                    color: .gold
                )
            )
            hasAny = true
        }
        if !items.isEmpty {
            if hasAny {
                segments.append(ViewMessage.Segment(text: ", "))
            }
            segments.append(contentsOf: itemSegments(for: items))
        }
        segments.append(ViewMessage.Segment(text: "]"))

        return ViewMessage(segments: segments, kind: .info)
    }

    private func isGameFinished() -> Bool {
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
                return ViewMessage(
                    segments: [
                        ViewMessage.Segment(text: "You picked up "),
                        colorizeItem(name: name, color: color),
                    ],
                    kind: .success
                )

            case let .itemDropped(name, color):
                return ViewMessage(
                    segments: [
                        ViewMessage.Segment(text: "You dropped "),
                        colorizeItem(name: name, color: color),
                    ],
                    kind: .success
                )

            case let .itemEaten(name, color):
                return ViewMessage(
                    segments: [
                        ViewMessage.Segment(text: "You ate "),
                        colorizeItem(name: name, color: color),
                        ViewMessage.Segment(text: "\nHP +1"),
                    ],
                    kind: .success
                )

            case let .chestOpened(item):
                if let item {
                    return ViewMessage(
                        segments: [
                            ViewMessage.Segment(text: "You found "),
                            colorizeItem(name: item.name, color: item.color),
                            ViewMessage.Segment(text: " in the chest!"),
                        ],
                        kind: .success
                    )
                }
                return ViewMessage(text: "Empty", kind: .info)

            case let .moved(direction):
                return ViewMessage(text: "You moved \(direction)", kind: .info)

            case let .goldPicked(coins):
                return ViewMessage(
                    segments: [
                        ViewMessage.Segment(text: "You picked up "),
                        ViewMessage.Segment(text: "\(coins) gold coins", color: .gold),
                    ],
                    kind: .success
                )
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

    private func itemSegments(for items: [any Item]) -> [ViewMessage.Segment] {
        var segments: [ViewMessage.Segment] = []

        for (index, item) in items.enumerated() {
            if index > 0 {
                segments.append(ViewMessage.Segment(text: ", "))
            }
            segments.append(colorizeItem(name: item.name, color: item.color))
        }

        return segments
    }

    private func colorizeItem(name: String, color: Color) -> ViewMessage.Segment {
        ViewMessage.Segment(
            text: "\(color) \(name)",
            color: mapToViewColor(color)
        )
    }

    private func mapToViewColor(_ color: Color) -> ViewMessage.TextColor {
        switch color {
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .yellow: return .yellow
        case .gold: return .gold
        case .roasted: return .roasted
        case .bright: return .bright
        }
    }
}

@testable import Model
import XCTest

final class GameCommandExecutionTests: XCTestCase {
    func testGetItemWithExactColorSucceeds() {
        let game = makeGame(
            roomItems: [Key(color: .red)],
            playerItems: []
        )

        let result = game.getItem(named: "key", color: .red)
        switch result {
        case let .success(.itemPicked(name, .red)):
            XCTAssertEqual(name, "key")
        default:
            XCTFail("Expected successful get for red key")
        }
    }

    func testGetItemWithWrongColorFails() {
        let game = makeGame(
            roomItems: [Key(color: .red)],
            playerItems: []
        )

        let result = game.getItem(named: "key", color: .blue)
        switch result {
        case .failure(.noSuchItemHere):
            break
        default:
            XCTFail("Expected noSuchItemHere for wrong color")
        }
    }

    func testDropItemWithExactColorSucceeds() {
        let game = makeGame(
            roomItems: [],
            playerItems: [Key(color: .green)]
        )

        let result = game.dropItem(named: "key", color: .green)
        switch result {
        case let .success(.itemDropped(name, .green)):
            XCTAssertEqual(name, "key")
        default:
            XCTFail("Expected successful drop for green key")
        }
    }

    func testOpenChestWithCorrectColorKeySucceeds() {
        let game = makeGame(
            roomItems: [Chest(color: .blue, item: Grail())],
            playerItems: [Key(color: .blue)]
        )

        let result = game.takeItemFromChest(color: .blue)
        switch result {
        case let .success(.chestOpened(item)):
            XCTAssertNotNil(item)
            XCTAssertEqual(item?.name, "The Holy Grail")
        default:
            XCTFail("Expected successful open for blue chest with blue key")
        }
    }

    func testOpenChestWithWrongKeyFails() {
        let game = makeGame(
            roomItems: [Chest(color: .yellow, item: Grail())],
            playerItems: [Key(color: .red)]
        )

        let result = game.takeItemFromChest(color: .yellow)
        switch result {
        case .failure(.noRightKey):
            break
        default:
            XCTFail("Expected noRightKey for yellow chest with red key")
        }
    }

    func testEatMeatIncreasesHpByOne() {
        let game = makeGame(
            roomItems: [],
            playerItems: [Meat()],
            health: 5
        )

        let result = game.eatItem(named: "hearty meat", color: .roasted)
        switch result {
        case let .success(.itemEaten(name, .roasted)):
            XCTAssertEqual(name, "hearty meat")
        default:
            XCTFail("Expected successful eat for meat")
        }

        XCTAssertEqual(game.getPlayerHP(), 6)
    }

    func testGetGoldStacksAcrossMultiplePicks() {
        let roomA = Room(
            items: [],
            doors: [.E],
            position: Position(x: 0, y: 0),
            gold: 15,
            isDark: false
        )
        let roomB = Room(
            items: [],
            doors: [.W],
            position: Position(x: 1, y: 0),
            gold: 15,
            isDark: false
        )
        let map = GameMap(rooms: [[roomA, roomB]])
        let player = Player(health: 10, position: Position(x: 0, y: 0), items: [])
        let game = Game(player: player, gameMap: map)

        _ = game.getGold()
        _ = game.movePlayer(direction: .E)
        _ = game.getGold()

        XCTAssertEqual(game.getPlayerGold(), 30)
    }

    private func makeGame(
        roomItems: [any Item],
        playerItems: [any Item],
        health: Int = 10
    ) -> Game {
        let room = Room(
            items: roomItems,
            doors: [],
            position: Position(x: 0, y: 0),
            gold: 0,
            isDark: false
        )
        let map = GameMap(rooms: [[room]])
        let player = Player(
            health: health,
            position: Position(x: 0, y: 0),
            items: playerItems
        )
        return Game(player: player, gameMap: map)
    }
}

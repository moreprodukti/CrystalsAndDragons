import XCTest
@testable import Model

final class GameRulesTests: XCTestCase {
    func testOpenChestUsesRequestedColor() {
        let position = Position(x: 0, y: 0)
        let redChest = Chest(color: .red, item: nil)
        let greenChest = Chest(color: .green, item: Grail())

        let room = Room(
            items: [redChest, greenChest],
            doors: [],
            position: position,
            gold: 0,
            isDark: false
        )
        let map = GameMap(rooms: [[room]])
        let player = Player(
            health: 10,
            position: position,
            items: [Key(color: .green)]
        )
        let game = Game(player: player, gameMap: map)

        let result = game.takeItemFromChest(color: .green)
        switch result {
        case let .success(.chestOpened(item)):
            XCTAssertNotNil(item)
            XCTAssertEqual(item?.name, "The Holy Grail")
        default:
            XCTFail("Expected successful opening of green chest")
        }

        XCTAssertFalse(redChest.isOpen)
    }

    func testDarkRoomWithoutTorchAllowsOnlyReturnDirection() {
        let start = Position(x: 0, y: 0)
        let dark = Position(x: 1, y: 0)

        let room0 = Room(
            items: [],
            doors: [.E],
            position: start,
            gold: 0,
            isDark: false
        )
        let room1 = Room(
            items: [],
            doors: [.W, .E],
            position: dark,
            gold: 0,
            isDark: true
        )
        let room2 = Room(
            items: [],
            doors: [.W],
            position: Position(x: 2, y: 0),
            gold: 0,
            isDark: false
        )

        let map = GameMap(rooms: [[room0, room1, room2]])
        let player = Player(health: 10, position: start, items: [])
        let game = Game(player: player, gameMap: map)

        _ = game.movePlayer(direction: .E)
        XCTAssertEqual(game.getPlayerPosition().x, 1)

        let blocked = game.movePlayer(direction: .E)
        switch blocked {
        case .failure(.blockedMove):
            break
        default:
            XCTFail("Expected blocked move from dark room in non-return direction")
        }

        let back = game.movePlayer(direction: .W)
        switch back {
        case .success(.moved(.W)):
            break
        default:
            XCTFail("Expected successful return move from dark room")
        }
    }

    func testDarkRoomWithTorchDoesNotRestrictExitDirection() {
        let start = Position(x: 0, y: 0)
        let dark = Position(x: 1, y: 0)

        let room0 = Room(
            items: [],
            doors: [.E],
            position: start,
            gold: 0,
            isDark: false
        )
        let room1 = Room(
            items: [],
            doors: [.W, .E],
            position: dark,
            gold: 0,
            isDark: true
        )
        let room2 = Room(
            items: [],
            doors: [.W],
            position: Position(x: 2, y: 0),
            gold: 0,
            isDark: false
        )

        let map = GameMap(rooms: [[room0, room1, room2]])
        let player = Player(health: 10, position: start, items: [Torchlight()])
        let game = Game(player: player, gameMap: map)

        _ = game.movePlayer(direction: .E)
        let next = game.movePlayer(direction: .E)
        switch next {
        case .success(.moved(.E)):
            break
        default:
            XCTFail("Expected free movement in dark room when player has torchlight")
        }
    }
}

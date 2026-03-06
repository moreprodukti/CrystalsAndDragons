@testable import Model
import XCTest

final class GameGeneratorTests: XCTestCase {
    func testGenerateInvalidRoomCountThrows() {
        let generator = GameGenerator()

        XCTAssertThrowsError(try generator.generate(roomCount: 0)) { error in
            guard case GameGenerationError.invalidRoomCount = error else {
                return XCTFail("Expected invalidRoomCount")
            }
        }
    }

    func testStartRoomIsNeverDark() throws {
        let generator = GameGenerator()

        for _ in 0 ..< 50 {
            let game = try generator.generate(roomCount: 12)
            let start = game.getPlayerPosition()
            XCTAssertFalse(game.isRoomDark(start))
        }
    }

    func testLabyrinthIsTraversableFromStart() throws {
        let generator = GameGenerator()

        for _ in 0 ..< 100 {
            let game = try generator.generate(roomCount: 20)
            let rooms = try unwrapRooms(from: game)
            let start = game.getPlayerPosition()

            let reachable = reachablePositions(from: start, in: rooms)
            let activePositions = activePositions(in: rooms, start: start)

            XCTAssertEqual(
                reachable,
                activePositions,
                "All active rooms must be reachable from start"
            )
        }
    }

    func testAllContentRoomsAreReachableFromStart() throws {
        let generator = GameGenerator()

        for _ in 0 ..< 100 {
            let game = try generator.generate(roomCount: 20)
            let rooms = try unwrapRooms(from: game)
            let start = game.getPlayerPosition()

            let reachable = reachablePositions(from: start, in: rooms)
            let contentRooms = contentPositions(in: rooms)

            XCTAssertTrue(
                contentRooms.isSubset(of: reachable),
                "Rooms with items/gold should be reachable from start"
            )
        }
    }

    private func unwrapRooms(from game: Game) throws -> [[Room]] {
        let gameMirror = Mirror(reflecting: game)
        guard let gameMap = gameMirror.children.first(where: { $0.label == "gameMap" })?.value as? GameMap else {
            throw XCTSkip("Unable to introspect gameMap from Game")
        }

        let mapMirror = Mirror(reflecting: gameMap)
        guard let rooms = mapMirror.children.first(where: { $0.label == "rooms" })?.value as? [[Room]] else {
            throw XCTSkip("Unable to introspect rooms from GameMap")
        }

        return rooms
    }

    private func reachablePositions(from start: Position, in rooms: [[Room]]) -> Set<String> {
        var visited = Set<String>()
        var queue: [Position] = [start]

        while !queue.isEmpty {
            let current = queue.removeFirst()
            let currentKey = key(for: current)
            guard !visited.contains(currentKey) else {
                continue
            }
            visited.insert(currentKey)

            for direction in rooms[current.y][current.x].doors {
                let next = move(from: current, direction: direction)
                guard isValid(next, in: rooms) else {
                    continue
                }
                if !visited.contains(key(for: next)) {
                    queue.append(next)
                }
            }
        }

        return visited
    }

    private func activePositions(in rooms: [[Room]], start: Position) -> Set<String> {
        var result = Set<String>()

        for y in 0 ..< rooms.count {
            for x in 0 ..< rooms[y].count {
                let room = rooms[y][x]
                if !room.doors.isEmpty || (x == start.x && y == start.y) {
                    result.insert("\(x),\(y)")
                }
            }
        }

        return result
    }

    private func contentPositions(in rooms: [[Room]]) -> Set<String> {
        var result = Set<String>()

        for y in 0 ..< rooms.count {
            for x in 0 ..< rooms[y].count {
                let room = rooms[y][x]
                if !room.items.isEmpty || room.gold > 0 {
                    result.insert("\(x),\(y)")
                }
            }
        }

        return result
    }

    private func move(from position: Position, direction: Direction) -> Position {
        switch direction {
        case .N:
            return Position(x: position.x, y: position.y - 1)
        case .S:
            return Position(x: position.x, y: position.y + 1)
        case .E:
            return Position(x: position.x + 1, y: position.y)
        case .W:
            return Position(x: position.x - 1, y: position.y)
        }
    }

    private func isValid(_ position: Position, in rooms: [[Room]]) -> Bool {
        guard position.y >= 0, position.y < rooms.count else { return false }
        guard position.x >= 0, position.x < rooms[position.y].count else { return false }
        return true
    }

    private func key(for position: Position) -> String {
        "\(position.x),\(position.y)"
    }
}

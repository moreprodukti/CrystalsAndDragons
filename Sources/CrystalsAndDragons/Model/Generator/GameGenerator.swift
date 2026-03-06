//
//  GameGenerator.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 05/03/26.
//

import Foundation

public enum GameGenerationError: Error {
    case invalidRoomCount
    case cannotSatisfyConstraints
}

public struct GameGenerator {
    private struct Cell: Hashable {
        let x: Int
        let y: Int
    }

    private static let healthBufferMultiplier: Int = 3
    private static let healthFlatBonus: Int = 6

    public init() {}

    public func generate(roomCount: Int, maxAttempts: Int = 100) throws -> Game {
        guard roomCount > 0 else {
            throw GameGenerationError.invalidRoomCount
        }

        let (rows, cols) = dimensions(for: roomCount)
        let activeCells = orderedCells(rows: rows, cols: cols).prefix(roomCount)
        let activeSet = Set(activeCells)
        let activeCount = activeSet.count
        let pairCount = numberOfPairs(forActiveRooms: activeCount)

        guard activeCount >= 3, pairCount >= 1 else {
            throw GameGenerationError.cannotSatisfyConstraints
        }

        for _ in 0 ..< maxAttempts {
            let doorGrid = generateConnectedDoors(rows: rows, cols: cols, active: activeSet)

            guard let start = activeSet.randomElement() else {
                continue
            }

            let roomForPairs = activeSet.filter { $0 != start }
            guard roomForPairs.count >= pairCount * 2 else {
                continue
            }

            let shuffled = roomForPairs.shuffled()
            let keyCells = Array(shuffled.prefix(pairCount))
            let chestCells = Array(shuffled.dropFirst(pairCount).prefix(pairCount))

            guard keyCells.count == pairCount, chestCells.count == pairCount else {
                continue
            }

            let grailKeyCell = keyCells[0]
            let grailChestCell = chestCells[0]

            let fromStart = bfsDistances(from: start, doors: doorGrid, rows: rows, cols: cols)
            let fromGrailKey = bfsDistances(from: grailKeyCell, doors: doorGrid, rows: rows, cols: cols)

            guard
                let stepsToKey = fromStart[grailKeyCell],
                let stepsKeyToChest = fromGrailKey[grailChestCell]
            else {
                continue
            }

            let minimumRequired = stepsToKey + stepsKeyToChest
            let health = max(
                10,
                minimumRequired * Self.healthBufferMultiplier + Self.healthFlatBonus
            )

            let colorsPool: [Color] = [.red, .green, .blue, .yellow]
            let pairColors = Array(colorsPool.shuffled().prefix(pairCount))

            let rooms = buildRooms(
                rows: rows,
                cols: cols,
                active: activeSet,
                doors: doorGrid,
                start: start,
                keyCells: keyCells,
                chestCells: chestCells,
                pairColors: pairColors,
                grailPairIndex: 0
            )
            ensureTorchlightIfNeeded(
                rooms: rooms,
                active: activeSet,
                start: start,
                doors: doorGrid,
                rows: rows,
                cols: cols
            )
            let player = Player(health: health, position: Position(x: start.x, y: start.y), items: [])
            let map = GameMap(rooms: rooms)
            return Game(player: player, gameMap: map)
        }

        throw GameGenerationError.cannotSatisfyConstraints
    }

    private func dimensions(for roomCount: Int) -> (rows: Int, cols: Int) {
        let cols = Int(ceil(Double(roomCount).squareRoot()))
        let rows = Int(ceil(Double(roomCount) / Double(cols)))
        return (rows, cols)
    }

    private func orderedCells(rows: Int, cols: Int) -> [Cell] {
        var cells: [Cell] = []
        for y in 0 ..< rows {
            for x in 0 ..< cols {
                cells.append(Cell(x: x, y: y))
            }
        }
        return cells
    }

    private func numberOfPairs(forActiveRooms activeCount: Int) -> Int {
        let raw = max(1, activeCount / 6)
        let limitByEmptyRooms = max(1, Int(Double(activeCount) * 0.6) / 2)
        return min(4, raw, limitByEmptyRooms)
    }

    private func generateConnectedDoors(rows: Int, cols: Int, active: Set<Cell>) -> [[Set<Direction>]] {
        var doors = Array(
            repeating: Array(repeating: Set<Direction>(), count: cols),
            count: rows
        )

        guard let start = active.randomElement() else {
            return doors
        }
        var visited: Set<Cell> = [start]
        var stack: [Cell] = [start]

        while let current = stack.last {
            let unvisitedNeighbors = neighbors(of: current, rows: rows, cols: cols)
                .filter { active.contains($0.cell) }
                .filter { !visited.contains($0.cell) }

            if let next = unvisitedNeighbors.randomElement() {
                connect(current, next.cell, direction: next.direction, doors: &doors)
                visited.insert(next.cell)
                stack.append(next.cell)
            } else {
                _ = stack.popLast()
            }
        }

        for y in 0 ..< rows {
            for x in 0 ..< cols {
                let cell = Cell(x: x, y: y)
                guard active.contains(cell) else {
                    continue
                }
                for neighbor in neighbors(of: cell, rows: rows, cols: cols) {
                    guard active.contains(neighbor.cell) else {
                        continue
                    }
                    let alreadyConnected = doors[y][x].contains(neighbor.direction)
                    guard !alreadyConnected else {
                        continue
                    }
                    if Double.random(in: 0 ... 1) < 0.22 {
                        connect(cell, neighbor.cell, direction: neighbor.direction, doors: &doors)
                    }
                }
            }
        }

        return doors
    }

    private func neighbors(of cell: Cell, rows: Int, cols: Int) -> [(cell: Cell, direction: Direction)] {
        var result: [(cell: Cell, direction: Direction)] = []

        if cell.y - 1 >= 0 {
            result.append((Cell(x: cell.x, y: cell.y - 1), .N))
        }
        if cell.y + 1 < rows {
            result.append((Cell(x: cell.x, y: cell.y + 1), .S))
        }
        if cell.x + 1 < cols {
            result.append((Cell(x: cell.x + 1, y: cell.y), .E))
        }
        if cell.x - 1 >= 0 {
            result.append((Cell(x: cell.x - 1, y: cell.y), .W))
        }

        return result
    }

    private func connect(_ a: Cell, _ b: Cell, direction: Direction, doors: inout [[Set<Direction>]]) {
        doors[a.y][a.x].insert(direction)
        doors[b.y][b.x].insert(opposite(of: direction))
    }

    private func opposite(of direction: Direction) -> Direction {
        switch direction {
        case .N:
            return .S
        case .S:
            return .N
        case .E:
            return .W
        case .W:
            return .E
        }
    }

    private func bfsDistances(from start: Cell, doors: [[Set<Direction>]], rows: Int, cols: Int) -> [Cell: Int] {
        var distances: [Cell: Int] = [start: 0]
        var queue: [Cell] = [start]
        var index = 0

        while index < queue.count {
            let current = queue[index]
            index += 1
            let baseDistance = distances[current] ?? 0

            for direction in doors[current.y][current.x] {
                let next = move(from: current, direction: direction)
                guard next.x >= 0, next.x < cols, next.y >= 0, next.y < rows else {
                    continue
                }
                guard distances[next] == nil else {
                    continue
                }
                distances[next] = baseDistance + 1
                queue.append(next)
            }
        }

        return distances
    }

    private func move(from cell: Cell, direction: Direction) -> Cell {
        switch direction {
        case .N:
            return Cell(x: cell.x, y: cell.y - 1)
        case .S:
            return Cell(x: cell.x, y: cell.y + 1)
        case .E:
            return Cell(x: cell.x + 1, y: cell.y)
        case .W:
            return Cell(x: cell.x - 1, y: cell.y)
        }
    }

    private func buildRooms(
        rows: Int,
        cols: Int,
        active: Set<Cell>,
        doors: [[Set<Direction>]],
        start: Cell,
        keyCells: [Cell],
        chestCells: [Cell],
        pairColors: [Color],
        grailPairIndex: Int
    ) -> [[Room]] {
        var roomGrid: [[Room]] = []

        for y in 0 ..< rows {
            var row: [Room] = []
            for x in 0 ..< cols {
                var items: [any Item] = []
                var gold = 0
                let cell = Cell(x: x, y: y)
                let isActive = active.contains(cell)
                var isDark = false

                if isActive {
                    for index in 0 ..< min(keyCells.count, pairColors.count) {
                        if cell == keyCells[index] {
                            items.append(Key(color: pairColors[index]))
                        }
                    }

                    for index in 0 ..< min(chestCells.count, pairColors.count) {
                        if cell == chestCells[index] {
                            if index == grailPairIndex {
                                items.append(Chest(color: pairColors[index], item: Grail()))
                            } else {
                                if Double.random(in: 0 ... 1) < 0.33 {
                                    items.append(Chest(color: pairColors[index], item: Meat()))
                                } else {
                                    items.append(Chest(color: pairColors[index], item: nil))
                                }
                            }
                        }
                    }

                    if !items.contains(where: { $0 is Chest }) {
                        if Double.random(in: 0 ... 1) < 0.33 {
                            items.append(Meat())
                        }
                    }

                    if Double.random(in: 0 ... 1) < 0.15 {
                        gold = Int.random(in: 5 ... 20)
                    }

                    if cell != start, Double.random(in: 0 ... 1) < 0.10 {
                        isDark = true
                    }

                    if !isDark, Double.random(in: 0 ... 1) < 0.10 {
                        items.append(Torchlight())
                    }
                }

                let room = Room(
                    items: items,
                    doors: isActive ? doors[y][x] : [],
                    position: Position(x: x, y: y),
                    gold: gold,
                    isDark: isDark
                )
                row.append(room)
            }
            roomGrid.append(row)
        }
        return roomGrid
    }

    private func ensureTorchlightIfNeeded(
        rooms: [[Room]],
        active: Set<Cell>,
        start: Cell,
        doors: [[Set<Direction>]],
        rows: Int,
        cols: Int
    ) {
        let hasDarkRooms = active.contains { cell in
            rooms[cell.y][cell.x].isDark
        }
        guard hasDarkRooms else {
            return
        }

        let distances = bfsDistances(from: start, doors: doors, rows: rows, cols: cols)
        let nearestDarkRoom = active
            .filter { rooms[$0.y][$0.x].isDark }
            .min { (distances[$0] ?? .max) < (distances[$1] ?? .max) }

        guard let targetDark = nearestDarkRoom else {
            return
        }

        guard let path = shortestPath(from: start, to: targetDark, doors: doors, rows: rows, cols: cols) else {
            return
        }

        let lightPath = path.dropLast().filter { !rooms[$0.y][$0.x].isDark }
        let hasTorchOnPath = lightPath.contains { cell in
            rooms[cell.y][cell.x].items.contains { $0 is Torchlight }
        }
        guard !hasTorchOnPath else {
            return
        }

        let target = lightPath.last ?? start
        rooms[target.y][target.x].putItem(Torchlight())
    }

    private func shortestPath(
        from start: Cell,
        to target: Cell,
        doors: [[Set<Direction>]],
        rows: Int,
        cols: Int
    ) -> [Cell]? {
        guard start != target else {
            return [start]
        }

        var parents: [Cell: Cell] = [:]
        var visited: Set<Cell> = [start]
        var queue: [Cell] = [start]
        var index = 0
        var found = false

        while index < queue.count {
            let current = queue[index]
            index += 1

            if current == target {
                found = true
                break
            }

            for direction in doors[current.y][current.x] {
                let next = move(from: current, direction: direction)
                guard next.x >= 0, next.x < cols, next.y >= 0, next.y < rows else {
                    continue
                }
                guard !visited.contains(next) else {
                    continue
                }
                visited.insert(next)
                parents[next] = current
                queue.append(next)
            }
        }

        guard found || parents[target] != nil else {
            return nil
        }

        var path: [Cell] = [target]
        var cursor = target
        while cursor != start {
            guard let parent = parents[cursor] else {
                return nil
            }
            path.append(parent)
            cursor = parent
        }
        return path.reversed()
    }
}

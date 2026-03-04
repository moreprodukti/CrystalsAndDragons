//
//  Inventory.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 05/03/26.
//

import Foundation

struct Inventory {
    private(set) var items: [any Item]

    init(items: [any Item] = []) {
        self.items = items
    }

    func hasItem(named itemName: String, color: Color) -> Bool {
        return items.contains { $0.name == itemName && $0.color == color }
    }

    mutating func add(_ item: any Item) {
        items.append(item)
    }

    mutating func take(named itemName: String, color: Color) -> (any Item)? {
        guard let index = items.firstIndex(where: { $0.name == itemName && $0.color == color }) else {
            return nil
        }
        return items.remove(at: index)
    }
}

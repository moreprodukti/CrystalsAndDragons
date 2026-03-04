//
//  HasItem.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation

protocol HasItem {
    var items: [Item] { get set }
}

extension HasItem {
    func hasItem(named itemName: String, color: Color) -> Bool {
        for item in items {
            if item.name == itemName, item.color == color {
                return true
            }
        }
        return false
    }

    mutating func addItem(_ item: Item) {
        items.append(item)
    }

    mutating func deleteItem(named itemName: String, color: Color) -> Item {
        var index = 0
        while index < items.count {
            if items[index].name == itemName && items[index].color == color {
                break
            }
            index += 1
        }
        return items.remove(at: index)
    }
}

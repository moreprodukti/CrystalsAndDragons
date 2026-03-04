//
//  Chest.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//
import Foundation

final class Chest: Item {
    let name: String = "chest"
    let description: String = "Mysterious chest"
    let color: Color
    var item: (any Item)?
    var isOpen: Bool = false

    init(color: Color, item: (any Item)?) {
        self.color = color
        self.item = item
    }

    func open() {
        isOpen = true
    }

    func takeItemFromChest() -> Item? {
        guard item != nil else {
            return nil
        }
        return item
    }
}

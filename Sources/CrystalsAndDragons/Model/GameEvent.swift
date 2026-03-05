//
//  GameEvent.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 05/03/26.
//

import Foundation

public enum GameEvent {
    case moved(Direction)
    case itemPicked(name: String, color: Color)
    case itemDropped(name: String, color: Color)
    case itemEaten(name: String, color: Color)
    case chestOpened(item: (any Item)?)
}

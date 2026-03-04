//
//  Item.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation

protocol Item {
    var name: String { get }
    var description: String { get }
    var color: Color { get }
}

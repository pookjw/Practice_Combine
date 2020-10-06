//
//  Coordinate.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation

public struct Coordinate {
    public let x: Int
    public let y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static func quadrantOf(x: Int, y: Int) -> String {
        var quadrant = ""
        
        switch (x, y) {
        case (1..., 1...):
            quadrant = "1"
        case (..<0, 1...):
            quadrant = "2"
        case (..<0, ..<0):
            quadrant = "3"
        case (1..., ..<0):
            quadrant = "4"
        default:
            quadrant = "boundary"
        }
        
        return quadrant
    }
}


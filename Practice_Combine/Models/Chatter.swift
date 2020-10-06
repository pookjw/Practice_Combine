//
//  Chatter.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation
import Combine

public struct Chatter {
    public let name: String
    public let message: CurrentValueSubject<String, Never>
    
    public init(name: String, message: String) {
        self.name = name
        self.message = CurrentValueSubject(message)
    }
}

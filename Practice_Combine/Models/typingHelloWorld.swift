//
//  typingHelloWorld.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/10/20.
//

import Foundation
import Combine

public let typingHelloWorld: [(TimeInterval, String)] = [
    (0.0, "H"),
    (0.1, "He"),
    (0.2, "Hel"),
    (0.3, "Hell"),
    (0.5, "Hello"),
    (0.6, "Hello "),
    (2.0, "Hello W"),
    (2.1, "Hello Wo"),
    (2.2, "Hello Wor"),
    (2.4, "Hello Worl"),
    (2.5, "Hello World")
]

let start = Date()
let deltaFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.negativePrefix = ""
    f.minimumFractionDigits = 1
    f.maximumFractionDigits = 1
    return f
}()

public var deltaTime: String {
    return deltaFormatter.string(for: Date().timeIntervalSince(start))!
}

public extension Subject where Output == String {
    /// A function that can feed delayed values to a subject for testing and simulation purposes
    func feed(with data: [(TimeInterval, String)]) {
        var lastDelay: TimeInterval = 0
        for entry in data {
            lastDelay = entry.0
            DispatchQueue.main.asyncAfter(deadline: .now() + entry.0) { [unowned self] in
                self.send(entry.1)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + lastDelay + 1.5) { [unowned self] in
            self.send(completion: .finished)
        }
    }
}

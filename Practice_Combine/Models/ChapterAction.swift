//
//  ChapterAction.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation

final class ChapterAction {
    let title: String
    let action: () -> ()
    
    init(title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = {
            print("===== \(title) =====")
            action()
            print("===== Called Action =====")
        }
    }
    
    init(title: String, waitAction: @escaping (DispatchSemaphore) -> ()) {
        self.title = title
        self.action = {
            let semaphore = DispatchSemaphore(value: 0)
            print("===== \(title) =====")
            waitAction(semaphore)
            print("===== Called Action =====")
        }
    }
}

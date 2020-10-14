//
//  BaseChapterViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

class BaseChapterViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

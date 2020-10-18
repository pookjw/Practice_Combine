//
//  Chapter14ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/18/20.
//

import Foundation
import Combine

class Chapter14ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "story", action: {
            let api = Chapter14API()
            
            api
                .story(id: 1000)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print($0) })
                .store(in: &subscriptions)
        }),
        
        .init(title: "mergedStories", action: {
            let api = Chapter14API()
            
            api
                .mergedStories(ids: [1000, 1001, 1002])
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print($0) })
                .store(in: &subscriptions)
        }),
        
        .init(title: "stories", action: {
            let api = Chapter14API()
            
            api.stories()
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print($0) })
                .store(in: &subscriptions)
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

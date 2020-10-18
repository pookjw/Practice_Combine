//
//  Chapter15ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/18/20.
//

import Foundation
import Combine

class Chapter15ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "HNReader", action: {})
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

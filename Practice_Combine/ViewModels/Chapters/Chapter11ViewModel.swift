//
//  Chapter11ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/14/20.
//

import Foundation
import Combine

class Chapter11ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "RunLoop", action: {
            let runLoop = RunLoop.main
            
            let subscription = runLoop
                .schedule(
                    after: runLoop.now,
                    interval: .seconds(1),
                    tolerance: .milliseconds(100)
                ) {
                    print("Timer fired")
                }
                .store(in: &subscriptions)
        }),
        
        .init(title: "Timer", action: {
            Timer
                .publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .scan(0) { counter, _ in counter + 1 }
                .sink { counter in
                    print("Counter is \(counter)")
                }
                .store(in: &subscriptions)
        }),
        
        .init(title: "DispatchQueue", action: {
            let queue = DispatchQueue.main
            let source = PassthroughSubject<Int, Never>()
            var counter = 0
            
            let cancellable = queue
                .schedule(after: queue.now, interval: .seconds(1)) {
                    source.send(counter)
                    counter += 1
                }
                .store(in: &subscriptions)
            
            let subscription = source
                .sink { print("Timer emitted \($0)") }
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

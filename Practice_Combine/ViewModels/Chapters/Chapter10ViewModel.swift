//
//  Chapter10ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/14/20.
//

import Foundation
import Combine

class Chapter10ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "print", action: {
            (1...3).publisher
                .print("publisher")
                .sink { _ in }
                .store(in: &subscriptions)
        }),
        
        .init(title: "print (custom)", action: {
            class TimeLogger: TextOutputStream {
                private var previous = Date()
                private let formatter = NumberFormatter()
                
                init() {
                    formatter.maximumFractionDigits = 5
                    formatter.minimumFractionDigits = 5
                }
                
                func write(_ string: String) {
                    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    let now = Date()
                    print("+\(formatter.string(for: now.timeIntervalSince(previous))!)s: \(string)")
                    previous = now
                }
            }
            
            (1...3).publisher
                .print("publisher", to: TimeLogger())
                .sink { _ in}
                .store(in: &subscriptions)
        }),
        
        .init(title: "handleEvents", action: {
            let request = URLSession.shared.dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com/")!)
            
            request
                .handleEvents(
                    receiveSubscription: { _ in print("Network request will start") },
                    receiveOutput: { _ in print("Network request data received") },
                    receiveCancel: { print("Network request cancelled") }
                )
                .sink(receiveCompletion: { completion in
                    print("Sink received completion: \(completion)")
                }, receiveValue: { (data, _) in
                    print("Sink received data: \(data)")
                })
                .store(in: &subscriptions)
        
        }),
        
        .init(title: "breakpoint", action: {
            (1...10)
                .publisher
                .breakpoint() // 아무 효과 없음
                .sink { print($0) }
                .store(in: &subscriptions)
        }),
        
        .init(title: "breakpoint (2)", action: {
            (1...10)
                .publisher
                .breakpoint(receiveOutput: { int in return int > 5})
                .sink { int in print(int) }
                .store(in: &subscriptions)
        }),
        
        .init(title: "breakpointOnError", action: {
            enum MyError: Error { case test }
            let publisher = PassthroughSubject<Int, MyError>()
            
            publisher
                .breakpointOnError()
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print($0) })
                .store(in: &subscriptions)
            
            publisher.send(completion: .failure(MyError.test))
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}


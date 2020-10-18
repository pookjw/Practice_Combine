//
//  Chapter13ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/14/20.
//

import Foundation
import Combine

class Chapter13ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        // request가 한 번만 돌아감
        .init(title: "share", action: {
            let shared = URLSession.shared
                .dataTaskPublisher(for: URL(string: "https://raywenderlich.com")!)
                .map(\.data)
                .print("shared")
                .share()
            
            print("subscribing first")
            
            let subscription1 = shared
                .sink(receiveCompletion: { _ in},
                      receiveValue: { print("subscription1 received: '\($0)'") }
                )
                .store(in: &subscriptions)
            
            print("subscribing second")
            
            let subscription2 = shared
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { print("subscription2 received: '\($0)'") }
                )
                .store(in: &subscriptions)
        }),
        
        .init(title: "without share", action: {
            let shared = URLSession.shared
                .dataTaskPublisher(for: URL(string: "https://raywenderlich.com")!)
                .map(\.data)
                .print("shared")
//                .share()
            
            print("subscribing first")
            
            let subscription1 = shared
                .sink(receiveCompletion: { _ in},
                      receiveValue: { print("subscription1 received: '\($0)'") }
                )
                .store(in: &subscriptions)
            
            print("subscribing second")
            
            let subscription2 = shared
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { print("subscription2 received: '\($0)'") }
                )
                .store(in: &subscriptions)
        }),
        
        // 이미 completed된 shared publisher에 sink를 하면 아무 일도 안 일어남
        .init(title: "share #2", action: {
            let shared = URLSession.shared
                .dataTaskPublisher(for: URL(string: "https://raywenderlich.com")!)
                .map(\.data)
                .print("shared")
                .share()
            
            print("subscribing first")
            
            let subscription1 = shared
                .sink(receiveCompletion: { _ in},
                      receiveValue: { print("subscription1 received: '\($0)'") }
                )
                .store(in: &subscriptions)
            
            //
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                print("subscribing second")
                let subscription2 = shared
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { print("subscription2 received: '\($0)'") }
                    )
                    .store(in: &subscriptions)
            }
        }),
        
        .init(title: "multicast", action: {
            let subject = PassthroughSubject<Data, URLError>()
            
            let multicated = URLSession
                .shared
                .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
                .map(\.data)
                .print("shared")
                .multicast(subject: subject)
                
            let subscription1 = multicated
                .sink(receiveCompletion: { _ in },
                      receiveValue: { print("subscription1 received: '\($0)'") })
                .store(in: &subscriptions)
            
            let subscription2 = multicated
                .sink(receiveCompletion: { _ in },
                      receiveValue: { print("subscription2 received: '\($0)'") })
                .store(in: &subscriptions)
            
            multicated
                .connect()
                .store(in: &subscriptions)
            subject.send(Data())
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

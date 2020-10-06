//
//  Chapter5ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation
import UIKit
import Combine

class Chapter5ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        /*
         prepend는 앞에 붙이는거고
         append는 뒤에
         */
        
        // 값을 추가
        .init(title: "prepend(Output)", action: {
            let publisher = [3, 4].publisher
            
            _ = publisher
                .prepend(1, 2)
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "prepend(Output) (2)", action: {
            let publisher = [3, 4].publisher
            
            _ = publisher
                .prepend(-1, 0)
                .prepend(1, 2)
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "prepend(Sequence)", action: {
            let publisher = [5, 6, 7].publisher
            
            _ = publisher
                .prepend([3, 4])
                .prepend(Set(1...2))
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "prepend(Sequence) (2)", action: {
            let publisher = [5, 6, 7].publisher
            
            _ = publisher
                .prepend([3, 4])
                .prepend(Set(1...2))
                .prepend(stride(from: 6, through: 11, by: 2))
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "prepend(Publisher)", action: {
            let publisher1 = [3, 4].publisher
            let publisher2 = [1, 2].publisher
            
            _ = publisher1
                .prepend(publisher2)
                .sink(receiveValue: { print($0) })
        }),
        
        // finish가 나야지만 prepend 된게 작동함
        .init(title: "prepend(Publisher) (2)", action: {
            let publisher1 = [3, 4].publisher
            let publisher2 = PassthroughSubject<Int, Never>()
            
            let subscription = publisher1
                .prepend(publisher2)
                .sink(receiveValue: { print($0) })
            
            publisher2.send(1)
            publisher2.send(2)
        }),
        
        .init(title: "prepend(Publisher) (3)", action: {
            let publisher1 = [3, 4].publisher
            let publisher2 = PassthroughSubject<Int, Never>()
            
            let subscription = publisher1
                .prepend(publisher2)
                .sink(receiveValue: { print($0) })
            
            publisher2.send(1)
            publisher2.send(2)
            publisher2.send(completion: .finished) // 이러면 3, 4가 나옴
        }),
        
        .init(title: "append(Output)", action: {
            let publisher = [1].publisher
            
            _ = publisher
                .append(2, 3)
                .append(4)
                .sink(receiveValue: { print($0) })
        }),
        
        // publisher가 finish가 안 됐으므로 3, 4, 5가 안 나옴
        .init(title: "append(Output) (2)", action: {
            let publisher = PassthroughSubject<Int, Never>()
            
            let subscriber = publisher
                .append(3, 4)
                .append(5)
                .sink(receiveValue: { print($0) })
            
            publisher.send(1)
            publisher.send(2)
        }),
        
        // publisher가 finish가 돼서 3, 4, 5가 나옴
        .init(title: "append(Output) (2)", action: {
            let publisher = PassthroughSubject<Int, Never>()
            
            let subscriber = publisher
                .append(3, 4)
                .append(5)
                .sink(receiveValue: { print($0) })
            
            publisher.send(1)
            publisher.send(2)
            
            publisher.send(completion: .finished)
        }),
        
        .init(title: "append(Sequence)", action: {
            let publisher = [1, 2, 3].publisher
            
            _ = publisher
                .append([4, 5])
                .append(Set([6, 7]))
                .append(stride(from: 8, through: 11, by: 2))
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "append(Publisher)", action: {
            let publisher1 = [1, 2].publisher
            let publisher2 = [3, 4].publisher
            
            _ = publisher1
                .append(publisher2)
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "switchToLatest", action: {
            let publisher1 = PassthroughSubject<Int, Never>()
            let publisher2 = PassthroughSubject<Int, Never>()
            let publisher3 = PassthroughSubject<Int, Never>()
            
            let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
            
            let subscription = publishers
                .switchToLatest()
                .sink(receiveCompletion: { _ in print("Completed!") },
                      receiveValue: { print($0) })
            
            publishers.send(publisher1)
            publisher1.send(1)
            publisher1.send(2)
            
            publishers.send(publisher2)
            publisher1.send(3)
            publisher2.send(4)
            publisher2.send(5)
            
            publishers.send(publisher3)
            publisher2.send(6)
            publisher3.send(7)
            publisher3.send(8)
            publisher3.send(9)
            
            publisher3.send(completion: .finished)
            publishers.send(completion: .finished)
        }),
        
        .init(title: "switchToLatest (2)", action: {
            let publisher1 = PassthroughSubject<Int, Never>()
            let publisher2 = PassthroughSubject<Int, Never>()
            let publisher3 = PassthroughSubject<Int, Never>()
            
            let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
            
            let subscription = publishers
//                .switchToLatest()
                .sink(receiveCompletion: { _ in print("Completed!") },
                      receiveValue: { print($0) })
            
            publishers.send(publisher1)
            publisher1.send(1)
            publisher1.send(2)
            
            publishers.send(publisher2)
            publisher1.send(3)
            publisher2.send(4)
            publisher2.send(5)
            
            publishers.send(publisher3)
            publisher2.send(6)
            publisher3.send(7)
            publisher3.send(8)
            publisher3.send(9)
            
            publisher3.send(completion: .finished)
            publishers.send(completion: .finished)
        }),
        
        .init(title: "switchToLatest - Network Request", action: {
            let url = URL(string: "https://source.unsplash.com/random")!
            
            func getImage() -> AnyPublisher<UIImage?, Never> {
                return URLSession
                    .shared
                    .dataTaskPublisher(for: url)
                    .map { data, _ in UIImage(data: data) }
                    .print("image")
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            
            let taps = PassthroughSubject<Void, Never>()
            
            let subscription = taps
                .map { _ in getImage() }
                .switchToLatest()
                .sink(receiveValue: { _ in })
            
            taps.send()
        }),
        
        // merge랑 combineLatest의 차이점은 검색해서 Marble을 볼 것
        .init(title: "merge", action: {
            let publisher1 = PassthroughSubject<Int, Never>()
            let publisher2 = PassthroughSubject<Int, Never>()
            
            let subscription = publisher1
                .merge(with: publisher2)
                .sink(receiveCompletion: { _ in print("Completed") },
                      receiveValue: { print($0) })
            
            // 다 나옴
            publisher1.send(1)
            publisher1.send(2)
            
            publisher2.send(3)
            publisher1.send(4)
            publisher2.send(5)
        }),
        
        // merge는 Event의 Type이 같아야 하는데, combineLatest는 달라도 됨 ($0, $1 이기 때문)
        .init(title: "combineLatest", action: {
            let publisher1 = PassthroughSubject<Int, Never>()
            let publisher2 = PassthroughSubject<String, Never>()
            
            let subscription = publisher1
                .combineLatest(publisher2)
                .sink(receiveCompletion: { _ in print("Completed") },
                      receiveValue: { print("P1: \($0), P2: \($1)") })
            
            publisher1.send(1)
            publisher1.send(2)
            
            publisher2.send("a")
            publisher2.send("b")
            
            publisher1.send(3)
            publisher2.send("c")
            
            publisher1.send(completion: .finished)
            publisher2.send(completion: .finished)
        }),
        
        // Marble을 볼 것
        .init(title: "zip", action: {
            let publisher1 = PassthroughSubject<Int, Never>()
            let publisher2 = PassthroughSubject<String, Never>()
            
            let subscription = publisher1
                .zip(publisher2)
                .sink(receiveCompletion: { _ in print("Completed") },
                      receiveValue: { print("P1: \($0), P2: \($1)") })
            
            publisher1.send(1)
            publisher1.send(2)
            
            publisher2.send("a")
            publisher2.send("b")
            
            publisher1.send(3)
            publisher2.send("c")
            publisher2.send("d")
            
            publisher1.send(completion: .finished)
            publisher2.send(completion: .finished)
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

//
//  Chapter3ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation
import Combine

class Chapter3ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "collect", action: {
//            ["A", "B", "C", "E"]
//                .publisher
//                .sink(
//                    receiveCompletion: { print($0) },
//                    receiveValue: { print($0) }
//                )
            
            _ = ["A", "B", "C", "D", "E"]
                .publisher
                .collect()
                .sink(
                    receiveCompletion: { print($0) },
                    receiveValue: { print($0) }
                )
            // Array로 나옴
        }),
        
        .init(title: "collect (2)", action: {
            _ = ["A", "B", "C", "D", "E"]
                .publisher
                .collect(2)
                .sink(
                    receiveCompletion: { print($0) },
                    receiveValue: { print($0) }
                )
        }),
        
        .init(title: "map", action: {
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            
            _ = [123, 4, 56]
                .publisher
                .map {
                    formatter.string(for: NSNumber(integerLiteral: $0)) ?? ""
                }
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "map (2)", action: {
            _ = [123, 4, 56]
                .publisher
                .map { $0 * 2 }
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "map key paths", action: {
            let publisher = PassthroughSubject<Coordinate, Never>()
            
            let subscription = publisher
                .map(\.x, \.y)
                .sink(receiveValue: { x, y in
                    print("The coordinate at (\(x), \(y)) is in quadrant", Coordinate.quadrantOf(x: x, y: y))
                })
            
            publisher.send(Coordinate(x: 10, y: -8))
            publisher.send(Coordinate(x: 0, y: 5))
            subscription.cancel()
        }),
        
        .init(title: "trymap", action: {
            _ = Just("Dictionary name that does not exist")
                .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print($0) })
        }),
        
        /*
         flatMap의 경우 Chatter의 reference가 바뀌었을 때만 receive가 동작하고,
         flatMap (2)의 경우 Chatter.message (String)의 reference가 비뀌었을 때 작동. 둘이 잘 비교해볼 것.
         */
        
        .init(title: "flatMap", action: {
            let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
            let james = Chatter(name: "James", message: "Hi, I'm James!")
            
            let chat = CurrentValueSubject<Chatter, Never>(charlotte)
            
            let subscription = chat
                .sink(receiveValue: { print($0.message.value) })
            
            charlotte.message.value = "Charlotte: How's it going?"
            chat.value = james
        }),
        
        .init(title: "flatMap (2)", action: {
            let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
            let james = Chatter(name: "James", message: "Hi, I'm James!")
            
            let chat = CurrentValueSubject<Chatter, Never>(charlotte)
            
            let subscription = chat
                .flatMap { $0.message }
                .sink(receiveValue: { print($0) })
            
            charlotte.message.value = "Charlotte: How's it going?"
            chat.value = james
        }),
        
        .init(title: "flatMap (3)", action: {
            let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
            let james = Chatter(name: "James", message: "Hi, I'm James!")
            
            let chat = CurrentValueSubject<Chatter, Never>(charlotte)
            
            let subscription = chat
                .flatMap { $0.message }
                .sink(receiveValue: { print($0) })
            
            charlotte.message.value = "Charlotte: How's it going?"
            chat.value = james
            
            james.message.value = "James: Doing great. You?"
            charlotte.message.value = "Charlotte: I'm doing fine thanks."
        }),
        
        // 여기서 maxPublisher의 개수는 Chatter (Publisher)의 개수임. message가 아님.
        .init(title: "flatMap (4)", action: {
            let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
            let james = Chatter(name: "James", message: "Hi, I'm James!")
            let morgan = Chatter(name: "Morgan", message: "Hey guys, what are you up to?")
            
            let chat = CurrentValueSubject<Chatter, Never>(charlotte)
            
            let subscription = chat
                .flatMap(maxPublishers: .max(2)) { $0.message }
                .sink(receiveValue: { print($0) })
            
            charlotte.message.value = "Charlotte: How's it going?"
            chat.value = james
            
            chat.value = morgan
            charlotte.message.value = "Did you hear something?"
        }),
        
        // replaceNil을 해도 type은 Optional
        .init(title: "replaceNil", action: {
            _ = ["A", nil, "C"]
                .publisher
                .replaceNil(with: "-") // Optional이면 안 됨
                .sink(receiveValue: { print(String(describing: $0)) }) // String?임
        }),
        
        .init(title: "replaceEmpty", action: {
            let empty = Empty<Int, Never>()
            
            _ = empty
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print($0) })
        }),
        
        .init(title: "replaceEmpty (2)", action: {
            let empty = Empty<Int, Never>()
            
            _ = empty
                .replaceEmpty(with: 1)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print($0) })
        }),
        
        // http://reactivex.io/documentation/operators/scan.html
        .init(title: "scan", action: {
            var dailyGainLoss: Int { .random(in: -10...10) }
            
            let august2019 = (0..<22)
                .map { _ in dailyGainLoss }
                .publisher
            
            // 50은 초기값
            _ = august2019
                .scan(50) { latest, current in
                    return max(0, latest + current)
                }
                .sink(receiveValue: { print($0) })
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

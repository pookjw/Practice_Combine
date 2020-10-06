//
//  Chapter4ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation
import Combine

class Chapter4ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "filter", action: {
            let numbers = (1...10).publisher
            
            _ = numbers
                .filter { $0.isMultiple(of: 3) }
                .sink(receiveValue: { print("\($0) is multiple of 3!") })
        }),
        
        .init(title: "removeDuplicates", action: {
            let words = "hey hey there! want to listen to mister mister ?"
                .components(separatedBy: " ")
                .publisher
            
            _ = words
                .removeDuplicates()
                .sink(receiveValue: { print($0) })
        }),
        
        // nil 필터링
        .init(title: "compactMap", action: {
            let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
            
            _ = strings
                .compactMap { Float($0) }
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "ignoreOutput", action: {
            let numbers = (1...10_000).publisher
            
            _ = numbers
                .ignoreOutput()
                .sink(receiveCompletion: { print("Completed with: \($0)") },
                      receiveValue: { print($0) })
        }),
        
        // true인 값만 event를 날리고, 그 전에 모든 event와 그 후 모든 event를 무시 (그 후가 true여도 무시, finish가 될 때만 first event가 작동)
        .init(title: "first", action: {
            let numbers = (1...9).publisher
            
            _ = numbers
                .first(where: { $0 % 2 == 0 })
                .sink(receiveCompletion: { print("Completed with: \($0)") },
                      receiveValue: { print($0) })
        }),
        
        // debug 용도
        .init(title: "print", action: {
            let numbers = (1...9).publisher
            
            _ = numbers
                .print("numbers")
                .first(where: { $0 % 2 == 0 })
                .sink(receiveCompletion: { print("Completed with: \($0)") },
                      receiveValue: { print($0) })
        }),
        
        // true를 만족하는 마지막 event만 (마지막의 기준은 finish)
        .init(title: "last", action: {
            let numbers = (1...9).publisher
            
            _ = numbers
                .last(where: { $0 % 2 == 0 })
                .sink(receiveCompletion: { print("Completed with: \($0)") },
                      receiveValue: { print($0) })
        }),
        
        .init(title: "last (2)", action: {
            let numbers = PassthroughSubject<Int, Never>()
            
            let subscription = numbers
                .last(where: { $0 % 2 == 0 })
                .sink(receiveCompletion: { print("Completed with: \($0)") },
                      receiveValue: { print($0) })
            
            numbers.send(1)
            numbers.send(2)
            numbers.send(3)
            numbers.send(4)
            numbers.send(5)
            numbers.send(6)
            
            // 다 안 나옴. finish가 안 됐기 때문
        }),
        
        .init(title: "last (3)", action: {
            let numbers = PassthroughSubject<Int, Never>()
            
            let subscription = numbers
                .last(where: { $0 % 2 == 0 })
                .sink(receiveCompletion: { print("Completed with: \($0)") },
                      receiveValue: { print($0) })
            
            numbers.send(1)
            numbers.send(2)
            numbers.send(3)
            numbers.send(4)
            numbers.send(5)
            numbers.send(6)
            
            // 다 안 나옴. finish가 안 됐기 때문
            
            numbers.send(completion: .finished) // 이제 6이 나옴
        }),
        
        .init(title: "dropFirst", action: {
            let numbers = (1...10).publisher
            
            // 9, 10만 나옴 - 8은 무시
            _ = numbers
                .dropFirst(8)
                .sink(receiveValue: { print($0) })
        }),
        
        /*
         drop과 prefix는 반대
         */
        
        .init(title: "drop", action: {
            let numbers = (1...10).publisher
            
            // 5부터 나옴 - 5 무시 안 됨
            _ = numbers
                .drop(while: { $0 % 5 != 0 })
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "drop (2)", action: {
            let numbers = (1...10).publisher
            
            // 5부터 나옴 - 5 무시 안 됨
            _ = numbers
                .drop(while: {
                    print("x")
                    return $0 % 5 != 0
                })
                .sink(receiveValue: { print($0) })
        }),
        
        .init(title: "drop(untilOutputFrom:)", action: {
            let isReady = PassthroughSubject<Void, Never>()
            let taps = PassthroughSubject<Int, Never>()
            
            let subscription = taps
                .drop(untilOutputFrom: isReady)
                .sink(receiveValue: { print($0) })
            
            (1...5).forEach { n in
                taps.send(n)
                
                if n == 3 { isReady.send() }
            }
        }),
        
        // 몇개만 가져오기
        .init(title: "prefix", action: {
            let numbers = (1...10).publisher
            
            _ = numbers
                .prefix(2)
                .sink(receiveCompletion: { print("Completed with: \($0)") },
                      receiveValue: { print($0) })
        }),
        
        /*
         drop과 prefix는 반대
         */
        
        .init(title: "prefix (2)", action: {
            let numbers = (1...10).publisher
            
            _ = numbers
                .prefix(while: { $0 < 3 })
                .sink(receiveCompletion: { print("Completed with: \($0)") },
                      receiveValue: { print($0) })
        }),
        
        .init(title: "prefix(untilOutputFrom:)", action: {
            let isReady = PassthroughSubject<Void, Never>()
            let taps = PassthroughSubject<Int, Never>()
            
            let subscription = taps
                .prefix(untilOutputFrom: isReady)
                .sink(receiveCompletion: { print("Completed with: \($0)")},
                      receiveValue: { print($0) })
            
            (1...5).forEach { n in
                taps.send(n)
                
                if n == 2 {
                    isReady.send()
                }
            }
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

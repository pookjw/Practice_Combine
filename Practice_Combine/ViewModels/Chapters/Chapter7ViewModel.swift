//
//  Chapter7ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation
import Combine

class Chapter7ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        // 당연히 completed가 돼야 함
        .init(title: "min", action: {
            let publisher = [1, -50, 246, 0].publisher
            
            _ = publisher
                .print("publisher")
                .min()
                .sink { print("Lowest value is \($0)") }
        }),
        
        .init(title: "min non-Comparable", action: {
            let publisher = ["12345", "ab", "hello world"]
                .compactMap { $0.data(using: .utf8) }
                .publisher
            
            _ = publisher
                .print("publisher")
                .min(by: { $0.count < $1.count })
                .sink { data in
                    let string = String(data: data, encoding: .utf8)!
                    print("Smallest data is \(string), \(data.count) bytes")
                }
        }),
        
        .init(title: "max", action: {
            let publisher = ["A", "F", "Z", "E"].publisher
            
            _ = publisher
                .print("publisher")
                .max()
                .sink { print("Highest value is \($0)") }
        }),
        
        .init(title: "first", action: {
            let publisher = ["A", "B", "C"].publisher
            
            _ = publisher
                .print("publisher")
                .first()
                .sink { print("First value is \($0)") }
        }),
        
        .init(title: "first(where:)", action: {
            let publisher = ["J", "O", "H", "N"].publisher
            
            _ = publisher
                .print("publisher")
                .first(where: { "Hello World".contains($0) })
                .sink { print("First match is \($0)") }
        }),
        
        // last(where:)도 동일
        .init(title: "last", action: {
            let publisher = ["A", "B", "C"].publisher
            
            _ = publisher
                .print("publisher")
                .last()
                .sink { print("Last value is \($0)") }
        }),
        
        .init(title: "output", action: {
            let publisher = ["A", "B", "C"].publisher
            
            _ = publisher
                .print("publisher")
                .output(at: 1)
                .sink(receiveValue: { print("Value at index 1 is \($0)") })
        }),
        
        .init(title: "output(in:)", action: {
            let publisher = ["A", "B", "C", "D", "E"].publisher
            
            _ = publisher
                .output(in: 1...3)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print("Value in range: \($0)") })
        }),
        
        // finish가 되는 시점에서 통과한 이벤트 개수
        .init(title: "count", action: {
            let publisher = ["A", "B", "C"].publisher
            
            _ = publisher
                .print("publisher")
                .count()
                .sink(receiveValue: { print("I have \($0) items") })
        }),
        
        // 이벤트가 해당 이벤트이면 true이고 바로 finish. false이면 sink에 이벤트가 안 날라감.
        // 모두 false이면 finish 되기 직전에 false가 sink됨. 즉, true 또는 false 둘중 하나는 무조건 sink 된다는 소리.
        .init(title: "contains", action: {
            let publisher = ["A", "B", "C", "D", "E"].publisher
            let letter = "C"
            
            _ = publisher
                .print("publisher")
                .contains(letter)
                .sink {
                    print($0 ? "Publisher emitted \(letter)" :
                            "Publisher never emitted \(letter)!")
                }
        }),
        
        .init(title: "contains (2)", action: {
            let publisher = ["A", "B", "C", "D", "E"].publisher
            let letter = "F"
            
            _ = publisher
                .print("publisher")
                .contains(letter)
                .sink {
                    print($0 ? "Publisher emitted \(letter)" :
                            "Publisher never emitted \(letter)!")
                }
        }),
        
        .init(title: "contains(where:)", action: {
            struct Person {
                let id: Int
                let name: String
            }
            
            let people = [
                (456, "Scott Gardner"),
                (123, "Shai Mishali"),
                (777, "Marin Todorov"),
                (214, "Florent Pillet")
            ]
            .map(Person.init)
            .publisher
            
            _ = people
                .contains(where: { $0.id == 800 })
                .sink { contains in
                    print(contains ? "Criteria matches!" : "Couldn't find a match for the criteria")
                }
        }),
        
        .init(title: "contains(where:) (2)", action: {
            struct Person {
                let id: Int
                let name: String
            }
            
            let people = [
                (456, "Scott Gardner"),
                (123, "Shai Mishali"),
                (777, "Marin Todorov"),
                (214, "Florent Pillet")
            ]
            .map(Person.init)
            .publisher
            
            _ = people
                .contains(where: { $0.id == 800 || $0.name == "Marin Todorov" })
                .sink { contains in
                    print(contains ? "Criteria matches!" : "Couldn't find a match for the criteria")
                }
        }),
        
        // 모든 이벤트들이 해당 조건을 만족하는지 검사. finish가 될 때 true 또는 false가 나옴
        .init(title: "allSatify", action: {
            let publisher = stride(from: 0, to: 5, by: 2).publisher
            
            _ = publisher
                .print("publisher")
                .allSatisfy { $0 % 2 == 0 }
                .sink { print($0 ? "All numbers are even" :
                                "Something is odd...") }
        }),
        
        .init(title: "allSatify (2)", action: {
            let publisher = stride(from: 0, to: 5, by: 1).publisher
            
            _ = publisher
                .print("publisher")
                .allSatisfy { $0 % 2 == 0 }
                .sink { print($0 ? "All numbers are even" :
                                "Something is odd...") }
        }),
        
        // scan과 reduce의 차이 : https://stackoverflow.com/questions/45350806/whats-difference-between-reduce-and-scan
        .init(title: "reduce", action: {
            let publisher = ["Hel", "lo", " ", "Wor", "ld", "!"].publisher
            
            _ = publisher
                .print("publisher")
                .reduce("") { accumulator, value in
                    accumulator + value
                }
                .sink(receiveValue: { print("Reduced into: \($0)") })
        }),
        
        .init(title: "reduce (2)", action: {
            let publisher = ["Hel", "lo", " ", "Wor", "ld", "!"].publisher
            
            _ = publisher
                .print("publisher")
                .reduce("", +)
                .sink(receiveValue: { print("Reduced into: \($0)") })
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

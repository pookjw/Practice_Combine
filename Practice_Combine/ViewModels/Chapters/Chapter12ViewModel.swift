//
//  Chapter12ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/14/20.
//

import Foundation
import Combine

class Chapter12ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "publisher(for:) #1", action: {
            let queue = OperationQueue()
            
            let subscription = queue
                .publisher(for: \.operationCount)
                .sink {
                    print("Outstanding operations in queue: \($0)")
                }
                .store(in: &subscriptions)
        }),
        
        .init(title: "publisher(for:) #2", action: {
            class TestObject: NSObject {
                @objc dynamic var integerProperty: Int = 0
            }
            
            let obj = TestObject()
            
            let subscription = obj.publisher(for: \.integerProperty)
                .sink(receiveValue: { print("integerProperty changes to \($0)") })
            
            obj.integerProperty = 100
            obj.integerProperty = 200
        }),
        
        .init(title: "publisher(for:) #3", action: {
            class TestObject: NSObject {
                // KVO를 하기 위해서는 Obj-C 타입이어야함
                // Swift 타입에서는 @Published (Chapter 8 마지막 참고!)
                @objc dynamic var integerProperty: Int = 0
                @objc dynamic var stringProperty: String = ""
                @objc dynamic var arrayProperty: [Float] = []
            }
            
            let obj = TestObject()
            
            let subscription = obj.publisher(for: \.integerProperty)
                .sink(receiveValue: { print("integerProperty changes to \($0)") })
            
            obj.integerProperty = 100
            obj.integerProperty = 200
            
            let subscription2 = obj.publisher(for: \.stringProperty)
                .sink(receiveValue: { print("stringProperty changes to \($0)") })
            
            let subscription3 = obj.publisher(for: \.arrayProperty)
                .sink(receiveValue: { print("arrayProperty changes to \($0)") })
            
            obj.stringProperty = "Hello"
            obj.arrayProperty = [1.0]
            obj.stringProperty = "World"
            obj.arrayProperty = [1.0, 2.0]
        }),
        
        .init(title: "publisher(for:options:)", action: {
            class TestObject: NSObject {
                @objc dynamic var integerProperty: Int = 0
            }
            
            let obj = TestObject()
            
            // .prior는 이전 값도 같이 날림
            let subscription = obj.publisher(for: \.integerProperty, options: [.prior])
                .sink(receiveValue: { print("integerProperty changes to \($0)") })
            
            obj.integerProperty = 100
            obj.integerProperty = 200
            obj.integerProperty = 300
            obj.integerProperty = 400
            obj.integerProperty = 500
        }),
        
        .init(title: "ObservableObject", action: {
            class MonitorObject: ObservableObject {
                @Published var someProperty = false
                @Published var someOtherProperty = ""
            }
            
            let object = MonitorObject()
            let subscription = object
                .objectWillChange // object가 변하기 전에 sink를 통과
                .sink { print("object will change") }
                .store(in: &subscriptions)
            
            object.someProperty = true
            object.someOtherProperty = "Hello world"
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

//
//  Chapter8ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/10/20.
//

import Foundation
import UIKit
import Combine

class Chapter8ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "assign", action: {
            class TestClass {
                var id: Int {
                    didSet(old) {
                        print(old)
                    }
                }
                init(id: Int) { self.id = id }
            }
            
            let test = TestClass(id: 3)
            let publisher = PassthroughSubject<Int, Never>()
            
            publisher
                .print("publisher")
                .assign(to: \.id, on: test)
                .store(in: &subscriptions)
            
            publisher.send(8)
            publisher.send(9)
            publisher.send(completion: .finished)
        }),
        
        // RxSwift에서 do랑 같음
        // 아래 코드의 경우 print -> handleEvents -> sink 순으로 출력됨. print랑 handleEvents 순서를 바꾸면 출력도 바뀜.
        .init(title: "handleEvents", action: {
            let publisher = (1...10).publisher
            
            publisher
                .print("[print]")
                .handleEvents(
                    receiveSubscription: { print("[handle] subscription: \($0)") },
                    receiveOutput: { print("[handle] output: \($0)") },
                    receiveCompletion: { print("[handle] completion: \($0)") },
                    receiveCancel: { print("[handle] cancel") },
                    receiveRequest: { print("[handle] request: \($0)") }
                )
                .sink(receiveCompletion: { print("[sink] completion: \($0)") },
                      receiveValue: { print("[sink] value: \($0)") })
                .store(in: &subscriptions)
        }),
        
        .init(title: "Save Photos", action: {
            let image: UIImage = UIImage(systemName: "gear")!
            PhotoWriter.save(image)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to save!", error.localizedDescription)
                    }
                }, receiveValue: { print("Saved with id: \($0)") })
                .store(in: &subscriptions)
        }),
        
        .init(title: "@Published", action: {
            class TestClass: ObservableObject {
                @Published var integer: Int = 0
            }
            let testClass = TestClass()
            
            testClass.$integer
                .sink(receiveValue: { print($0)} )
                .store(in: &subscriptions)
            
            testClass.integer = 3
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

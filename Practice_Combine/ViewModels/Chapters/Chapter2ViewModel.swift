//
//  Chapter2ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation
import Combine

final class Chapter2ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "Publisher", action: {
            let myNotification = Notification.Name("MyNotification")
            let publisher = NotificationCenter.default.publisher(for: myNotification, object: nil)
            let center = NotificationCenter.default
            
            let observer = center.addObserver(
                forName: myNotification,
                object: nil,
                queue: nil,
                using: { notification in
                    print("Notification received!")
                }
            )
            
            center.post(name: myNotification, object: nil)
            center.removeObserver(observer)
        }),
        
        .init(title: "Subscriber", action: {
            let myNotification = Notification.Name("MyNotification")
            let publisher = NotificationCenter.default.publisher(for: myNotification)
            let center = NotificationCenter.default
            
            let subscription = publisher
                .sink(receiveValue: { _ in // Notification
                    print("Notification received from a publisher!")
                })
            center.post(name: myNotification, object: nil)
            subscription.cancel()
        }),
        
        .init(title: "Just", action: {
            let just = Just("Hello world!")
            
            _ = just
                .sink(receiveCompletion: { print("Received completion", $0) },
                      receiveValue: { print("Received value", $0) }
                )
        }),
        
        .init(title: "assign(to:on:)", action: {
            class SomeObject {
                var value: String = "" {
                    didSet { print(value) }
                }
            }
            
            let object = SomeObject()
            let publisher = ["Hello", "world!"].publisher
            
            _ = publisher.assign(to: \.value, on: object)
            print(object.value)
        }),
        
        .init(title: "Cancellable", action: {
            let myNotification = Notification.Name("MyNotification")
            let publisher = NotificationCenter.default.publisher(for: myNotification)
            let center = NotificationCenter.default
            let subscription = publisher
                .sink(receiveValue: { _ in
                    print("Notification received from a publisher!")
                })
            center.post(name: myNotification, object: nil)
            subscription.cancel()
        }),
        
        .init(title: "Custom Subscriber", action: {
            let publisher = (1...6).publisher
            
            final class IntSubscriber: Subscriber {
                typealias Input = Int
                typealias Failure = Never
                
                func receive(subscription: Subscription) {
                    subscription.request(.max(3))
                }
                
                func receive(_ input: Int) -> Subscribers.Demand {
                    print("Received value", input)
                    return .none
                }
                
                func receive(completion: Subscribers.Completion<Never>) {
                    print("Received completion", completion)
                }
            }
            
            let subscriber = IntSubscriber()
            publisher.subscribe(subscriber)
        }),
        
        // https://heckj.github.io/swiftui-notes/#reference-future
        .init(title: "Future", waitAction: { semaphore in
            var subscriptions = Set<AnyCancellable>()
            
            func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
                .init { promise in
                    print("Original")
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        promise(.success(integer + 1))
                        semaphore.signal()
                    }
                }
            }
            
            let future = futureIncrement(integer: 1, afterDelay: 2)
            future
                .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
                .store(in: &subscriptions)
            future
                .sink(receiveCompletion: { print("Second", $0) }, receiveValue: { print("Second", $0) })
                .store(in: &subscriptions)
            
            semaphore.wait() // Closure가 끝나면 subscriptions 안에 있는 것들이 다 사라져서, completion이 돌아가기 전에 wait하는걸 넣어줘야함
        }),
        
        .init(title: "PassthroughSubject", action: {
            enum MyError: Error {
                case test
            }
            
            final class StringSubscriber: Subscriber {
                typealias Input = String
                typealias Failure = MyError
                
                func receive(subscription: Subscription) {
                    subscription.request(.max(2))
                }
                
                func receive(_ input: String) -> Subscribers.Demand {
                    print("Received value", input)
                    return input == "World" ? .max(1) : .none // max를 1로 설정하는게 아니라 1 증가
                }
                
                func receive(completion: Subscribers.Completion<MyError>) {
                    print("Received completion", completion)
                }
            }
            
            let subject = PassthroughSubject<String, MyError>()
            let subscriber = StringSubscriber()
            subject.subscribe(subscriber)
            let subscription = subject
                .sink(
                    receiveCompletion: { completion in
                        print("Received completion (sink)", completion)
                    }, receiveValue: { value in
                        print("Received value (sink)", value)
                    }
                )
            
            subject.send("Hello")
            subject.send("World")
            subject.send("Hellos")
            subject.send("Helloss")
            subject.send("Hellosss")
            subject.send("World")
            subject.send("World")
            subject.send("World")
            subject.send("World")
            subject.send("World")
            
            subscription.cancel()
            subject.send("Still there?") // 안 나옴
        }),
        
        .init(title: "PassthroughSubject (2)", action: {
            enum MyError: Error {
                case test
            }
            
            final class StringSubscriber: Subscriber {
                typealias Input = String
                typealias Failure = MyError
                
                func receive(subscription: Subscription) {
                    subscription.request(.max(2))
                }
                
                func receive(_ input: String) -> Subscribers.Demand {
                    print("Received value", input)
                    return input == "World" ? .max(1) : .none
                }
                
                func receive(completion: Subscribers.Completion<MyError>) {
                    print("Received completion", completion)
                }
            }
            
            let subject = PassthroughSubject<String, MyError>()
            let subscriber = StringSubscriber()
            subject.subscribe(subscriber)
            
            let subscription = subject
                .sink(
                    receiveCompletion: { completion in
                        print("Received completion (sink)", completion)
                    },
                    receiveValue: { value in
                        print("Received value (sink)", value)
                    }
                )
            
            subject.send("Hello")
            subject.send("World")
            subscription.cancel()
            subject.send("Still there?") // sink는 안 나오고 그냥은 나옴
            
            subject.send(completion: .finished)
            subject.send("How about another one?") // 안 나옴
        }),
        
        .init(title: "PassthroughSubject (3)", action: {
            enum MyError: Error {
                case test
            }
            
            final class StringSubscriber: Subscriber {
                typealias Input = String
                typealias Failure = MyError
                
                func receive(subscription: Subscription) {
                    subscription.request(.max(2))
                }
                
                func receive(_ input: String) -> Subscribers.Demand {
                    print("Received value", input)
                    return input == "World" ? .max(1) : .none
                }
                
                func receive(completion: Subscribers.Completion<MyError>) {
                    print("Received completion", completion)
                }
            }
            
            let subject = PassthroughSubject<String, MyError>()
            let subscriber = StringSubscriber()
            subject.subscribe(subscriber)
            
            let subscription = subject
                .sink(
                    receiveCompletion: { completion in
                        print("Received completion (sink)", completion)
                    },
                    receiveValue: { value in
                        print("Received value (sink)", value)
                    }
                )
            
            subject.send("Hello")
            subject.send("World")
            subscription.cancel()
            subject.send("Still there?") // sink는 안 나오고 그냥은 나옴
            
            subject.send(completion: .failure(MyError.test))
            subject.send("How about another one?") // 안 나옴
        }),
        
        .init(title: "CurrentValueSubject", action: {
            var subscriptions = Set<AnyCancellable>()
            let subject = CurrentValueSubject<Int, Never>(0)
            
            subject
                .sink(receiveValue: { print($0) })
                .store(in: &subscriptions)
            
            subject.send(1)
            subject.send(2)
            
            print(subject.value)
            
            subject.send(3)
            print(subject.value)
        }),
        
        .init(title: "CurrentValueSubject (2)", action: {
            var subscriptions = Set<AnyCancellable>()
            let subject = CurrentValueSubject<Int, Never>(0)
            
            subject
                .print()
                .sink(receiveValue: { print("Second subscription:", $0) })
                .store(in: &subscriptions)
            
            subject.send(1)
            subject.send(2)
            
            print(subject.value)
            
            subject.value = 3
            print(subject.value)
            
            subject.send(completion: .finished)
        }),
        
        .init(title: "Dynamically adjusting Demand", action: {
            final class IntSubscriber: Subscriber {
                typealias Input = Int
                typealias Failure = Never
                
                func receive(subscription: Subscription) {
                    subscription.request(.max(2))
                }
                
                func receive(_ input: Int) -> Subscribers.Demand {
                    print("Received value", input)
                    
                    switch input {
                    case 1:
                        return .max(2)
                    case 3:
                        return .max(1)
                    default:
                        return .none
                    }
                }
                
                func receive(completion: Subscribers.Completion<Never>) {
                    print("Received completion", completion)
                }
            }
            
            let subscriber = IntSubscriber()
            
            let subject = PassthroughSubject<Int, Never>()
            
            subject.subscribe(subscriber)
            
            [1, 2, 3, 4, 5, 6].forEach {
                subject.send($0)
            }
        }),
        
        .init(title: "Type erasure", action: {
            let subject: PassthroughSubject<Int, Never> = .init()
            let publisher: AnyPublisher<Int, Never> = subject.eraseToAnyPublisher()
            
            let subscription = publisher
                .sink(receiveValue: { print($0) })
            subject.send(0)
            subscription.cancel()
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

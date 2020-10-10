//
//  Chapter6ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import Foundation
import Combine

class Chapter6ViewModel: ObservableObject {
    let loadLastAction: Bool = false
    static var cancellableBag = Set<AnyCancellable>()
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "Timer (autoconnect)", action: {
            let valuesPerSecond = 1.0
            let sourcePublisher = PassthroughSubject<Date, Never>()
            
            Timer
                .publish(every: 1.0 / valuesPerSecond, on: .current, in: .common)
                .autoconnect()
                .subscribe(sourcePublisher)
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            sourcePublisher
                .sink(
                    receiveCompletion: { _ in print("Completed!") },
                    receiveValue: { print($0) }
                )
                .store(in: &Chapter6ViewModel.cancellableBag)
        }),
        
        // 1.5초 후에 들어온 Event가 발생
        .init(title: "delay", action: {
            let delayInSeconds = 1.5
            let sourcePublisher = PassthroughSubject<Date, Never>()
            let delayedPublisher = sourcePublisher
                .delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)
            
            let valuesPerSecond = 1.0
            
            Timer
                .publish(every: 1.0 / valuesPerSecond, on: .current, in: .common)
                .autoconnect()
                .subscribe(sourcePublisher)
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            delayedPublisher
                .sink(
                    receiveCompletion: { _ in print("Completed!") },
                    receiveValue: { print($0) }
                )
                .store(in: &Chapter6ViewModel.cancellableBag)
        }),
        
        // Array로 4개로 묶여서 나옴
        .init(title: "collect", action: {
            let valuesPerSecond = 1.0
            let collectTimeStride = 4
            
            let sourcePublisher = PassthroughSubject<Date, Never>()
            let collectedPublisher = sourcePublisher
                .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
            
            Timer
                .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
                .autoconnect()
                .subscribe(sourcePublisher)
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            collectedPublisher
                .sink(
                    receiveCompletion: { _ in print("Completed!") },
                    receiveValue: { print($0) }
                )
                .store(in: &Chapter6ViewModel.cancellableBag)
        }),
        
        // Array로 4개로 묶여서 나왔는데, 그 Array를 Publisher로 변환하면 각각 나옴
        .init(title: "collect (2)", action: {
            let valuesPerSecond = 1.0
            let collectTimeStride = 4
            
            let sourcePublisher = PassthroughSubject<Date, Never>()
            let collectedPublisher = sourcePublisher
                .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
                .flatMap { dates in dates.publisher }
            
            Timer
                .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
                .autoconnect()
                .subscribe(sourcePublisher)
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            collectedPublisher
                .sink(
                    receiveCompletion: { _ in print("Completed!") },
                    receiveValue: { print($0) }
                )
                .store(in: &Chapter6ViewModel.cancellableBag)
        }),
        
        .init(title: "collect #2", action: {
            let valuesPerSecond = 1.0
            let collectTimeStride = 4
            let collectMaxCount = 2
            
            let sourcePublisher = PassthroughSubject<Date, Never>()
            let collectedPublisher = sourcePublisher
                .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTimeStride), collectMaxCount))
                .flatMap { dates in dates.publisher }
            
            Timer
                .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
                .autoconnect()
                .subscribe(sourcePublisher)
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            collectedPublisher
                .sink(
                    receiveCompletion: { _ in print("Completed!") },
                    receiveValue: { print($0) }
                )
                .store(in: &Chapter6ViewModel.cancellableBag)
        }),
        
        // debounce와 throttle의 차이점 : https://medium.com/fantageek/throttle-vs-debounce-in-rxswift-86f8b303d5d4
        .init(title: "debounce", action: {
            let subject = PassthroughSubject<String, Never>()
            
            let debounded = subject
                .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
                .share()
            
            subject
                .sink { string in
                    print("+\(deltaTime)s: Subject emitted: \(string)")
                }
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            debounded
                .sink { string in
                    print("+\(deltaTime)s: Debounded emitted: \(string)")
                }
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            subject.feed(with: typingHelloWorld)
        }),
        
        .init(title: "throttle", action: {
            let throttleDelay = 1.0
            let subject = PassthroughSubject<String, Never>()
            
            let throttled = subject
                .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: false)
                .share()
            
            subject
                .sink { string in
                    print("+\(deltaTime)s: Subject emitted: \(string)")
                }
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            throttled
                .sink { string in
                    print("+\(deltaTime)s: Throttled emitted: \(string)")
                }
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            subject.feed(with: typingHelloWorld)
        }),
        
        .init(title: "timeout", action: {
            let subject = PassthroughSubject<String, Never>()
            let timedOutSubject = subject.timeout(.seconds(3), scheduler: DispatchQueue.main)
            timedOutSubject
                .print("Test")
                .sink(receiveCompletion: { _ in print("Completed!") }, receiveValue: { print($0) })
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            subject.send("Ah")
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                subject.send("Oh")
            }
        }),
        
        .init(title: "timeout (2)", action: {
            enum TimeoutError: Error {
                case timedOut
            }
            
            let subject = PassthroughSubject<Void, TimeoutError>()
            let timedOutSubject = subject.timeout(.seconds(5), scheduler: DispatchQueue.main, customError: { .timedOut })
            
            timedOutSubject
                .print("Test")
                .sink(receiveCompletion: { _ in print("Completed!") }, receiveValue: { print($0) })
                .store(in: &Chapter6ViewModel.cancellableBag)
        }),
        
        // 이전 이벤트와의 시간차를 측정함
        .init(title: "mesureInterval", action: {
            let subject = PassthroughSubject<String, Never>()
            let measureSubject = subject.measureInterval(using: DispatchQueue.main)
            
            subject
                .sink { print("+\(deltaTime)s: Subject emitted: \($0)") }
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            measureSubject
                .sink { print("+\(deltaTime)s: Measure emitted: \($0)") }
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            subject.feed(with: typingHelloWorld)
        }),
        
        // 이전 이벤트와의 시간차를 측정함
        .init(title: "mesureInterval (2)", action: {
            let subject = PassthroughSubject<String, Never>()
            let measureSubject = subject.measureInterval(using: DispatchQueue.main)
            
            subject
                .sink { print("+\(deltaTime)s: Subject emitted: \($0)") }
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            measureSubject
                .sink { print("+\(deltaTime)s: Measure emitted: \(Double($0.magnitude) / 1_000_000_000.0)") }
                .store(in: &Chapter6ViewModel.cancellableBag)
            
            subject.feed(with: typingHelloWorld)
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

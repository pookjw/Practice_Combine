//
//  Chapter9ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/10/20.
//

import Foundation
import Combine

class Chapter9ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "URLSession", action: {
            guard let url = URL(string: "https://mysite.com/mydata.json") else { return }
            
            URLSession.shared
                .dataTaskPublisher(for: url)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let err) = completion {
                            print("Retrieving data failed with error \(err)")
                        }
                    },
                    receiveValue: { (data, reponse) in
                        print("Retrieved data of size \(data.count), response = \(reponse)")
                    }
                )
                .store(in: &subscriptions)
        }),
        
        .init(title: "JSONDecoder", action: {
            guard let url = URL(string: "https://mysite.com/mydata.json") else { return }
            
            URLSession.shared
                .dataTaskPublisher(for: url)
                
//                .tryCompactMap { data, _ in
//                    try JSONDecoder().decode(MyType.self, from: data)
//                }
                
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let err) = completion {
                            print("Retrieving data failed with error \(err)")
                        }
                    },
                    receiveValue: { (data, reponse) in
                        print("Retrieved data of size \(data.count), response = \(reponse)")
                    }
                )
                .store(in: &subscriptions)
        }),
        
        .init(title: "JSONDecoder (2)", action: {
            guard let url = URL(string: "https://mysite.com/mydata.json") else { return }
            
            URLSession.shared
                .dataTaskPublisher(for: url)
                
                .map(\.data)
//                .decode(type: MyType.self, decoder: JSONDecoder())
                
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let err) = completion {
                            print("Retrieving data failed with error \(err)")
                        }
                    },
                    receiveValue: { (data) in
                        print("Retrieved data of size \(data.count))")
                    }
                )
                .store(in: &subscriptions)
        }),
        
        /*
         share()는 여러개를 subscribe를 하면 subscribe를 모두 마치기 전에 이벤트를 다 날려버리는 단점이 있으므로
         multicase()를 통해 subscribe가 다 끝날 때 까지 기다릴 수 있음. 준비가 끝나면 .connect()를 써서 이벤트를 받아올 수 있다.
         */
        .init(title: "multicast", action: {
            let url = URL(string: "https://raywenderlich.com")!
            
            let publisher = URLSession.shared
                .dataTaskPublisher(for: url)
                .map(\.data)
                .multicast { PassthroughSubject<Data, URLError>() }
            
            publisher
                .sink(receiveCompletion: { completion in
                    if case .failure(let err) = completion {
                        print("Sink1 Retrieving data failed with error \(err)")
                    }
                }, receiveValue: { object in
                    print("Sink1 Retrieved object \(object)")
                })
                .store(in: &subscriptions)
            
            publisher
                .sink(receiveCompletion: { completion in
                    if case .failure(let err) = completion {
                        print("Sink2 Retrieving data failed with error \(err)")
                    }
                }, receiveValue: { object in
                    print("Sink2 Retrieved object \(object)")
                })
                .store(in: &subscriptions)
            
            // connect()
            publisher
                .connect()
                .store(in: &subscriptions)
        }),
        
        .init(title: "share", action: {
            let url = URL(string: "https://raywenderlich.com")!
            
            let publisher = URLSession.shared
                .dataTaskPublisher(for: url)
                .map(\.data)
                .share()
            
            publisher
                .sink(receiveCompletion: { completion in
                    if case .failure(let err) = completion {
                        print("Sink1 Retrieving data failed with error \(err)")
                    }
                }, receiveValue: { object in
                    print("Sink1 Retrieved object \(object)")
                })
                .store(in: &subscriptions)
            
            publisher
                .sink(receiveCompletion: { completion in
                    if case .failure(let err) = completion {
                        print("Sink2 Retrieving data failed with error \(err)")
                    }
                }, receiveValue: { object in
                    print("Sink2 Retrieved object \(object)")
                })
                .store(in: &subscriptions)
        })
    ]
    
    func getLastAction() -> (() -> ()) {
        guard let lastAction: ChapterAction = actions.last else {
            return {}
        }
        return lastAction.action
    }
}

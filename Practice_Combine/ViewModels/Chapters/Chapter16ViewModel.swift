//
//  Chapter16ViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/18/20.
//

import Combine
import UIKit

class Chapter16ViewModel: ObservableObject {
    let loadLastAction: Bool = true
    
    let actions: [ChapterAction] = [
        .init(title: "Test Action", action: { print("Hi") }),
        
        .init(title: "Never sink", action: {
            Just("Hello") // 기본적으로 Error type이 Never
                .sink(receiveValue: { print($0)} )
                .store(in: &subscriptions)
        }),
        
        .init(title: "setFailureType", action: {
            enum MyError: Error { case ohNo }
            
            Just("Hello")
                .setFailureType(to: MyError.self) // Never로 되어 있는걸 바꿈
                .eraseToAnyPublisher() // Erase를 해도 Error type은 유지
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(.ohNo): print("Finished with Oh No!")
                        case .finished: print("Finished successfully!")
                        }
                    },
                    receiveValue: {
                        print("Got value: \($0)")
                    }
                )
                .store(in: &subscriptions)
        }),
        
        // assign을 쓰려면 반드시 에러가 Never여야함!!!
        .init(title: "assign", action: {
            class Person {
                let id = UUID()
                var name = "Unknown"
            }
            
            let person = Person()
            print("1", person.name)
            
            Just("Shai")
                // assign을 쓰려면 반드시 에러가 Never여야함!
//                .setFailureType(to: Error.self)
                .handleEvents(
                    receiveCompletion: { _ in print("2", person.name) }
                )
                .assign(to: \.name, on: person)
                .store(in: &subscriptions)
        }),
        
        .init(title: "assertNoFailure", action: {
            enum MyError: Error { case ohNo }
            
            Just("Hello")
                .setFailureType(to: MyError.self)
                .tryMap { _ in throw MyError.ohNo }
                .assertNoFailure() // CRASH
                .sink(receiveValue: { print("Got value: \($0) ") })
                .store(in: &subscriptions)
        }),
        
        .init(title: "tryMap (before)", action: {
            enum NameError: Error {
                case tooShort(String)
                case unknown
            }
            
            let names = ["Scott", "Marin", "Shai", "Florent"].publisher
            
            names
                .map { value in return value.count }
                .sink(
                    receiveCompletion: { print("Completed with \($0)") },
                    receiveValue: { print("Got value: \($0)") }
                )
                .store(in: &subscriptions)
        }),
        
        .init(title: "tryMap (after)", action: {
            enum NameError: Error {
                case tooShort(String)
                case unknown
            }
            
            let names = ["Scott", "Marin", "Shai", "Florent"].publisher
            
            names
                .tryMap { value -> Int in
                    let length = value.count
                    
                    guard length >= 5 else {
                        throw NameError.tooShort(value)
                    }
                    
                    return value.count
                }
                .sink(
                    receiveCompletion: { print("Completed with \($0)") },
                    receiveValue: { print("Got value: \($0)") }
                )
                .store(in: &subscriptions)
        }),
        
        .init(title: "map vs tryMap", action: {
            enum NameError: Error {
                case tooShort(String)
                case unknown
            }
            
            Just("Hello")
                .setFailureType(to: NameError.self)
                .map { $0 + " World!" }
                .sink(
                    // map으로 하면 completion의 에러 타입이 NameError이지만, tryMap으로 하면 에러 타입이 Error로 나온다
                    // 따라서 tryMap에서 한 가지 에러 타입만이 아닌, 여러가지 에러 타입을 던질 수가 있다
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("Done!")
                        case .failure(.tooShort(let name)):
                            print("\(name) is too short!")
                        case .failure(.unknown):
                            print("An unknown name error occured")
                        }
                    },
                    receiveValue: { print("Got value \($0)") }
                )
                .store(in: &subscriptions)
        }),
        
        .init(title: "mapError", action: {
            enum NameError: Error {
                case tooShort(String)
                case unknown
            }
            
            Just("Hello")
                .setFailureType(to: NameError.self)
                .tryMap { $0 + " World!" }
                // tryMap으로 에러 타입이 지워졌는데, 그걸 다시 NameError로 설정
                // 그러면 sink의 receiveCompletion .failure에는 Error가 NameError
                .mapError { $0 as? NameError ?? .unknown }
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("Done!")
                        case .failure(.tooShort(let name)):
                            print("\(name) is too short!")
                        case .failure(.unknown):
                            print("An unknown name error occured")
                        }
                    },
                    receiveValue: { print("Got value \($0)") }
                )
                .store(in: &subscriptions)
        }),
        
        .init(title: "mapError (2)", action: {
            enum NameError: Error {
                case tooShort(String)
                case unknown
            }
            
            Just("Hello")
                .setFailureType(to: NameError.self)
                .tryMap { throw NameError.tooShort($0) }
                // tryMap으로 에러 타입이 지워졌는데, 그걸 다시 NameError로 설정
                // 그러면 sink의 receiveCompletion .failure에는 Error가 NameError
                .mapError { $0 as? NameError ?? .unknown }
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("Done!")
                        case .failure(.tooShort(let name)):
                            print("\(name) is too short!")
                        case .failure(.unknown):
                            print("An unknown name error occured")
                        }
                    },
                    receiveValue: { print("Got value \($0)") }
                )
                .store(in: &subscriptions)
        }),
        
        .init(title: "Joke API", action: {
            class DadJokes {
                struct Joke: Codable {
                  let id: String
                  let joke: String
                }
                
                func getJoke(id: String) -> AnyPublisher<Joke, Error> {
                    let url = URL(string: "https://icanhazdadjoke.com/j/\(id)")!
                    var request = URLRequest(url: url)
                    request.allHTTPHeaderFields = ["Accept": "application/json"]
                    
                    return URLSession
                        .shared
                        .dataTaskPublisher(for: request)
                        .map(\.data)
                        .decode(type: Joke.self, decoder: JSONDecoder())
                        .eraseToAnyPublisher()
                }
            }
            
            let api = DadJokes()
            let jokeID = "9prWnjyImyd"
            let badJokeID = "123456"
            
            api
                .getJoke(id: jokeID)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print("Got joke: \($0)") })
                .store(in: &subscriptions)
        }),
        
        .init(title: "Joke API (mapError)", action: {
            class DadJokes {
                enum Error: Swift.Error, CustomStringConvertible {
                    case network
                    case jokeDoesntExist(id: String)
                    case parsing
                    case unknown
                    
                    var description: String {
                        switch self {
                        case .network:
                            return "Request to API Server failed"
                        case .parsing:
                            return "Failed parting response from server"
                        case .jokeDoesntExist(let id):
                            return "Joke with ID \(id) doesn't exist"
                        case .unknown:
                            return "An unknown error occured"
                        }
                    }
                }
                
                struct Joke: Codable {
                  let id: String
                  let joke: String
                }
                
                func getJoke(id: String) -> AnyPublisher<Joke, Error> {
                    let url = URL(string: "https://icanhazdadjoke.com/j/\(id)")!
                    var request = URLRequest(url: url)
                    request.allHTTPHeaderFields = ["Accept": "application/json"]
                    
                    return URLSession
                        .shared
                        .dataTaskPublisher(for: request)
                        .map(\.data)
                        .decode(type: Joke.self, decoder: JSONDecoder())
                        .mapError { error -> DadJokes.Error in
                            switch error {
                            case is URLError: return .network
                            case is DecodingError: return .parsing
                            default: return .unknown
                            }
                        }
                        .eraseToAnyPublisher()
                }
            }
            
            let api = DadJokes()
            let jokeID = "9prWnjyImyd"
            let badJokeID = "123456"
            
            api
                .getJoke(id: badJokeID)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print("Got joke: \($0)") })
                .store(in: &subscriptions)
        }),
        
        .init(title: "Joke API (tryMap and Fail)", action: {
            class DadJokes {
                enum Error: Swift.Error, CustomStringConvertible {
                    case network
                    case jokeDoesntExist(id: String)
                    case parsing
                    case unknown
                    
                    var description: String {
                        switch self {
                        case .network:
                            return "Request to API Server failed"
                        case .parsing:
                            return "Failed parting response from server"
                        case .jokeDoesntExist(let id):
                            return "Joke with ID \(id) doesn't exist"
                        case .unknown:
                            return "An unknown error occured"
                        }
                    }
                }
                
                struct Joke: Codable {
                  let id: String
                  let joke: String
                }
                
                func getJoke(id: String) -> AnyPublisher<Joke, Error> {
                    
                    // Fail
                    guard id.rangeOfCharacter(from: .letters) != nil else {
                        return Fail<Joke, Error>(error: .jokeDoesntExist(id: id))
                            .eraseToAnyPublisher()
                    }
                    
                    let url = URL(string: "https://icanhazdadjoke.com/j/\(id)")!
                    var request = URLRequest(url: url)
                    request.allHTTPHeaderFields = ["Accept": "application/json"]
                    
                    return URLSession
                        .shared
                        .dataTaskPublisher(for: request)
//                        .map(\.data)
                        
                        .tryMap { data, _ in
                            guard let obj = try? JSONSerialization.jsonObject(with: data),
                                  let dict = obj as? [String: Any],
                                  dict["status"] as? Int == 404 else {
                                return data
                            }
                            
                            throw DadJokes.Error.jokeDoesntExist(id: id)
                        }
                        
                        .decode(type: Joke.self, decoder: JSONDecoder())
                        .mapError { error -> DadJokes.Error in
                            switch error {
                            case is URLError: return .network
                            case is DecodingError: return .parsing
                            default: return error as? DadJokes.Error ?? .unknown
                            }
                        }
                        .eraseToAnyPublisher()
                }
            }
            
            let api = DadJokes()
            let jokeID = "9prWnjyImyd"
            let badJokeID = "123456"
            
            api
                .getJoke(id: badJokeID)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { print("Got joke: \($0)") })
                .store(in: &subscriptions)
        }),
        
        
        .init(title: "PhotoService (handleEvents, retry)", action: {
            let photoService = PhotoService()
            
            photoService
                .fetchPhoto(quality: .high)
                
                .handleEvents(
                    receiveSubscription: { _ in print("Trying...") },
                    receiveCompletion: {
                        guard case .failure(let error) = $0 else {
                            return
                        }
                        print("Got error: \(error)")
                    })
                // 에러가 발생하면 subscription부터 다시 시도
                .retry(3)
                
                .sink(receiveCompletion: { print("\($0)") },
                      receiveValue: { image in
                        print("Got image: \(image)")
                      })
                .store(in: &subscriptions)
        }),
        
        .init(title: "PhotoService (handleEvents, retry) #2", action: {
            let photoService = PhotoService()
            
            photoService
                .fetchPhoto(quality: .high, failingTimes: 2)
                
                .handleEvents(
                    receiveSubscription: { _ in print("Trying...") },
                    receiveCompletion: {
                        guard case .failure(let error) = $0 else {
                            return
                        }
                        print("Got error: \(error)")
                    })
                // 에러가 발생하면 subscription부터 다시 시도
                .retry(3)
                
                .sink(receiveCompletion: { print("\($0)") },
                      receiveValue: { image in
                        print("Got image: \(image)")
                      })
                .store(in: &subscriptions)
        }),
        
        .init(title: "PhotoService (replaceError)", action: {
            let photoService = PhotoService()
            
            photoService
                .fetchPhoto(quality: .high)
                .handleEvents(
                    receiveSubscription: { _ in print("Trying...") },
                    receiveCompletion: {
                        guard case .failure(let error) = $0 else {
                            return
                        }
                        print("Got error: \(error)")
                    })
                .retry(3)
                
                // handleEvents의 completion에서는 Error가 들어 오는데, replaceError가 된 후 completion에는 Error가 안 들어옴
                .replaceError(with: UIImage(named: "na.jpg")!)
                
                .sink(receiveCompletion: { print("\($0)") },
                      receiveValue: { image in
                        print("Got image: \(image)")
                      })
                .store(in: &subscriptions)
        }),
        
        .init(title: "PhotoService (catch)", action: {
            let photoService = PhotoService()
            
            photoService
                .fetchPhoto(quality: .high)
                .handleEvents(
                    receiveSubscription: { _ in print("Trying...") },
                    receiveCompletion: {
                        guard case .failure(let error) = $0 else {
                            return
                        }
                        print("Got error: \(error)")
                    })
                .retry(3)
                
                // replaceError와 다르게 Publisher가 나옴
                .catch { error -> PhotoService.Publisher in
                    print("Failed fetching high quality, falling back to low quality")
                    return photoService.fetchPhoto(quality: .low)
                }
                //
                
                .sink(receiveCompletion: { print("\($0)") },
                      receiveValue: { image in
                        print("Got image: \(image)")
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

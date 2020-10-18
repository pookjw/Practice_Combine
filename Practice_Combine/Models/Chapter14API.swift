//
//  Chapter14API.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/18/20.
//

import Foundation
import Combine

public struct Story: Codable {
    public let id: Int
    public let title: String
    public let by: String
    public let time: TimeInterval
    public let url: String
}

extension Story: Comparable {
    public static func < (lhs: Story, rhs: Story) -> Bool {
        return lhs.time > rhs.time
    }
}

extension Story: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\n\(title)\nby \(by)\n\(url)\n-----"
    }
}

/* */

struct Chapter14API {
    
    enum Error: LocalizedError {
        case addressUnreachable(URL)
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "The server responded with garbage."
            case .addressUnreachable(let url): return "\(url.absoluteString) is unreachable."
            }
        }
    }
    
    enum EndPoint {
        static let baseURL = URL(string: "https://hacker-news.firebaseio.com/v0/")!
        
        case stories
        case story(Int)
        
        var url: URL {
            switch self {
            case .stories:
                return EndPoint.baseURL.appendingPathComponent("newstories.json")
            case .story(let id):
                return EndPoint.baseURL.appendingPathComponent("item/\(id).json")
            }
        }
    }
    
    var maxStories = 10
    
    private let decoder = JSONDecoder()
    
    /* */
    
    private let apiQueue = DispatchQueue(label: "Chapter14API", qos: .default, attributes: .concurrent)
    
    func story(id: Int) -> AnyPublisher<Story, Error> {
        return URLSession
            .shared
            .dataTaskPublisher(for: EndPoint.story(id).url)
            .receive(on: apiQueue)
            .map(\.data)
            .decode(type: Story.self, decoder: decoder)
            .catch { _ in Empty<Story, Error>() }
            .eraseToAnyPublisher()
    }
    
    /* */
    
    func mergedStories(ids storyIDs: [Int]) -> AnyPublisher<Story, Error> {
        let storyIDs = Array(storyIDs.prefix(maxStories)) // .prefix의 Quick Help를 볼 것!
        
        precondition(!storyIDs.isEmpty)
        
        let initialPublisher = story(id: storyIDs[0])
        let remainder = Array(storyIDs.dropFirst())
        
        return remainder
            .reduce(initialPublisher) { combined, id in
                return combined
                    .merge(with: story(id: id))
                    .eraseToAnyPublisher()
            }
    }
    
    /* */
    
    func stories() -> AnyPublisher<[Story], Error> {
        return URLSession
            .shared
            .dataTaskPublisher(for: EndPoint.stories.url)
            .map(\.data)
            .decode(type: [Int].self, decoder: decoder)
            .mapError { error -> Chapter14API.Error in
                switch error {
                case is URLError: return Error.addressUnreachable(EndPoint.stories.url)
                default: return Error.invalidResponse
                }
            }
            .filter { !$0.isEmpty }
            .flatMap { storyIDs in
                return self.mergedStories(ids: storyIDs)
            }
            .scan([]) { stories, story in
                return stories + [story]
            }
            .map { $0.sorted() }
            .eraseToAnyPublisher()
    }
}

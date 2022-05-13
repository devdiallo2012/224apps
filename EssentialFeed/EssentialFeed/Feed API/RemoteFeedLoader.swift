//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdoulaye Diallo on 5/11/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load(completion: @escaping (Result) -> Void){
        client.get(from: url) { result in
            switch result {
                case let .success(data, response):
                    if let items = try? FeedItemMapper.map(data, response) {
                        completion(.success(items))
                    } else{
                        completion(.failure(.invalidData))
                    }
                case .failure:
                    completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    public struct Item : Decodable{
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    //MARK: - Funcs
    
    static var OK_200: Int { return 200}
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else { throw RemoteFeedLoader.Error.invalidData }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map {$0.item}
    }
}



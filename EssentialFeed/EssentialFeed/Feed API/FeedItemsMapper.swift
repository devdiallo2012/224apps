//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Abdoulaye Diallo on 5/13/22.
//

import Foundation

internal class FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item : Decodable{
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    //MARK: - Funcs
    
    private static var OK_200: Int { return 200}
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else { throw RemoteFeedLoader.Error.invalidData }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map {$0.item}
    }
}

//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abdoulaye Diallo on 5/11/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult)-> Void)
}

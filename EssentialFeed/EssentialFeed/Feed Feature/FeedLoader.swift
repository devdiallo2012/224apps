//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abdoulaye Diallo on 5/11/22.
//

import Foundation

public enum LoadFeedResult{
    case success([FeedItem])
    case failure(Error)
}


public protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadFeedResult)-> Void)
}

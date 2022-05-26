//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Abdoulaye Diallo on 5/25/22.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeedCall(completion: @escaping DeletionCompletion )
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

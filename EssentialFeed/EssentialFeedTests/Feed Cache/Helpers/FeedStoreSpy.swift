//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/27/22.
//

import Foundation
import EssentialFeed


//MARK: - FeedStore Spy

class FeedStoreSpy: FeedStore {
    
    
    private (set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions = [DeletionCompletion] ()
    private var insertionCompletions = [InsertionCompletion] ()
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    func deleteCachedFeedCall(completion: @escaping DeletionCompletion ){
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int  = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionCompletions[index](nil)
    }
    
    func retrieve() {
        receivedMessages.append(.retrieve)
    }
}

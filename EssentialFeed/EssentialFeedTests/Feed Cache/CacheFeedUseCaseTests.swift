//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/25/22.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeedCall(){
        deleteCachedFeedCallCount += 1
    }
}

class LocalFeedLoader {
    let store: FeedStore
    init(store: FeedStore){
        self.store = store
    }
    
    func save(_ items: [FeedItem]){
        store.deleteCachedFeedCall()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        let store = FeedStore()
        
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion(){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
//MARK: - Helpers
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "", location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

}

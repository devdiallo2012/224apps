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
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion(){
       let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
//MARK: - Helpers
    
    private func makeSUT( file: StaticString = #filePath, line: UInt = #line) ->(sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackMemoryLeaks(store, file:file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "", location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

}

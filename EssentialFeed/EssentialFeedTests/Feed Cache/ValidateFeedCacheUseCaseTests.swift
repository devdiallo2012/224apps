//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/30/22.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func  test_validateCache_deleteCacheOnRetrievalError(){
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func  test_validateCache_doesNotDeleteCacheOnEmptyCache(){
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func  test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOld(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldCache = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldCache)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func  test_validateCache_deletesCacheSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldCache = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldCache)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func  test_validateCache_deletesMoreThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldCache = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldCache)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,  file: StaticString = #filePath, line: UInt = #line) ->(sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file:file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}

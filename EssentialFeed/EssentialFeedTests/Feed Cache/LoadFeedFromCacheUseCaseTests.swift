//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/27/22.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval(){
        let (sut, store) = makeSUT()
        
        sut.load(){_ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError(){
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldCache = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldCache)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldCache = fixedCurrentDate.adding(days: -7)
        
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldCache)
        }
    }
    
    func test_load_deliversNoImagesMoreThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldCache = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldCache)
        }
    }
    
    func  test_load_hasNoSideEffectsOnRetrievalError(){
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func  test_load_hasNoSideEffectsOnEmptyCache(){
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func  test_load_hasNoSideEffectsOnLessThanSevenDaysOld(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldCache = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        sut.load{_ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldCache)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func  test_load_deleteCacheOnSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldCache = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        sut.load{_ in }
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldCache)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func  test_load_deleteCacheOnMoreThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldCache = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        sut.load{_ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldCache)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader?  = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }
        
        
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
        
    }
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,  file: StaticString = #filePath, line: UInt = #line) ->(sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file:file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void ){
        let exp = expectation(description: "wait for completion")
        
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedImages), .success(expectedImages)):
                    XCTAssertEqual(receivedImages, expectedImages)
                    
                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(receivedError, expectedError)
                    
                default:
                    XCTFail("Expected result \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}

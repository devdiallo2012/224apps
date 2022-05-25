//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/25/22.
//

import XCTest
import EssentialFeed

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeedCall(completion: @escaping DeletionCompletion )
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}



class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date ){
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void){
        store.deleteCachedFeedCall { [weak self] error in
            guard let self = self  else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.store.insert(items, timestamp: self.currentDate()) { [weak self] error in
                    guard  self !=  nil else { return }
                    completion(error)
                    
                }
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items){ _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items){ _ in }
        store.completeDeletion(with:deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfullDeletion(){
        
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: {timestamp})
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items){ _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError(){
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with:deletionError)
        }
    }
    
    func test_save_failsOnInsertionError(){
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion(){
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader?  = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [Error?]()
        
        sut?.save([uniqueItem()]){ receivedResult.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader?  = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [Error?]()
        sut?.save([uniqueItem()]){ receivedResult.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,  file: StaticString = #filePath, line: UInt = #line) ->(sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file:file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?,
                        when action: () -> (), file: StaticString = #filePath, line: UInt = #line){
        let exp = expectation(description: "Wait for completion")
        var receivedError: Error?
        sut.save([uniqueItem()]){ error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as  NSError?, expectedError, file: file, line: line)
    }
    
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "", location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any errpr", code: 1)
    }
    
    //MARK: - FeedStore Spy
    
    private class FeedStoreSpy: FeedStore {
        
        
        private (set) var receivedMessages = [ReceivedMessage]()
        private var deletionCompletions = [DeletionCompletion] ()
        private var insertionCompletions = [InsertionCompletion] ()
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
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
        
        func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
        }
        
        func completeInsertion(with error: Error, at index: Int  = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0){
            insertionCompletions[index](nil)
        }
    }
}

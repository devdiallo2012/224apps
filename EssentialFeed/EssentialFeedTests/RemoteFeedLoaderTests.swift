//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/11/22.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestsDataFromURL(){
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-url.com")!

        _ = RemoteFeedLoader(client: client, url: url)
        
        XCTAssertNil(client.requestedURL )
    }
    
    func test_load_requestsDataFromURL(){
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        var requestedURLs = [URL]()
        
         func get(from url: URL) {
            requestedURL = url
             requestedURLs.append(url)
        }
    }
}

//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/11/22.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load(){
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
     func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestsDataFromURL(){
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-url.com")!

        _ = RemoteFeedLoader(client: client, url: url)
        
        XCTAssertNil(client.requestedURL )
    }
    
    func test_load_requestsDataFromURL(){
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
}

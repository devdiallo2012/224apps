//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/11/22.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
    
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init(){
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL )
    }
}

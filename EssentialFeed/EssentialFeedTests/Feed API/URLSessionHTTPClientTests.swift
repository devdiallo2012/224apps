//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/13/22.
//

import XCTest


class URLSessionHTTPClient {
    private let session: URLSession
    init(session:  URLSession){
        self.session  = session
    }
    
    func get(from url: URL){
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskFromURL(){
        let url  = URL(string: "http://www.any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url:url, task: task)
        let sut = URLSessionHTTPClient(session: session)
    
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    
    
    //MARK: -Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        var stubs  = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return  stubs[url] ?? FakeURLSessionDataTask()
        }
        
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    private class URLSessionDataTaskSpy : URLSessionDataTask {
        var resumeCallCount: Int = 0
        
        override func resume() {
            resumeCallCount += 1
        }
        
    }
}

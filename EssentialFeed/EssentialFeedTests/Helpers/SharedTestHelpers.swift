//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/30/22.
//

import Foundation

func anyNSError() -> NSError {
   return NSError(domain: "any errpr", code: 1)
}

func anyURL() -> URL {
   return URL(string: "http://any-url.com")!
}

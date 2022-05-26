//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/16/22.
//

import XCTest

extension XCTestCase {
     func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential Memory leak", file: file, line: line)
        }
    }
}

//
//  FeedCacheTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Abdoulaye Diallo on 5/30/22.
//

import Foundation
import EssentialFeed

 func uniqueImageFeed() -> (models: [FeedImage],  local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, local)
}

 func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "", location: nil, url: anyURL())
}

public  extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date{
        return (self  + seconds)
    }
}

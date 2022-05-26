//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdoulaye Diallo on 5/25/22.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date ){
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void){
        store.deleteCachedFeedCall { [weak self] error in
            guard let self = self  else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with:completion)
                
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        self.store.insert(items.total(), timestamp: self.currentDate()) { [weak self] error in
            guard  self !=  nil else { return }
            completion(error)
        }
    }
    
}


private extension Array where Element == FeedItem {
    func total() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}

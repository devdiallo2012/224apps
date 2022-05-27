//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Abdoulaye Diallo on 5/26/22.
//

import Foundation

internal struct RemoteFeedItem : Decodable{
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

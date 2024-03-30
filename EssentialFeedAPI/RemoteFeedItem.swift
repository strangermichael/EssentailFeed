//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2023/12/31.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
  internal let id: UUID
  internal let description: String?
  internal let location: String?
  internal let image: URL
}

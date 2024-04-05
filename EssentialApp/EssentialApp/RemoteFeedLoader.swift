//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation
import EssentialFeed
import EssentialFeedAPI

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
  convenience init(client: HTTPClient, url: URL) {
    self.init(client: client, url: url, mapper: FeedItemMapper.map)
  }
}

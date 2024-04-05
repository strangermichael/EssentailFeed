//
//  RemoteImageCommentFeedLoader.swift
//  EssentialFeedAPI
//
//  Created by Shengjun Xia on 2024/4/4.
//

import Foundation
import EssentialFeed

public typealias RemoteImageCommentLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentLoader {
  convenience init(client: HTTPClient, url: URL) {
    self.init(client: client, url: url, mapper: ImageCommentsMapper.map)
  }
}

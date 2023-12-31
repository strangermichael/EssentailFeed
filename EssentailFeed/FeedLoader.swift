//
//  FeedLoader.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/10/19.
//

import Foundation

public enum LoadFeedResult {
  case success([FeedImage])
  case failure(Error)
}

public protocol FeedLoader {
  func load(completion: @escaping (LoadFeedResult) -> Void)
}

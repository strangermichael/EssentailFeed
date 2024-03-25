//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Shengjun Xia on 2024/3/25.
//

import Foundation
import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {
  private let decoratee: FeedLoader
  private let cache: FeedCache
  
  public init(decoratee: FeedLoader, cache: FeedCache) {
    self.decoratee = decoratee
    self.cache = cache
  }
  
  public func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load { [weak self] result in
      completion(result.map({ feed in
        self?.cache.save(items: feed, completion: { _ in })
        return feed
      }))
    }
  }
}

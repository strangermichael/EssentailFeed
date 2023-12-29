//
//  LocalFeedLoader.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/29.
//

import Foundation

public final class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  public func save(items: [FeedItem], completion: @escaping (Error?) -> Void) {
    store.deleteCachedFeed { [weak self] cacheDeletionError in
      guard let this = self else { return }
      if let cacheDeletionError = cacheDeletionError {
        completion(cacheDeletionError) //only call back once, since will call back once get insert result
      } else {
        this.cache(items: items, completion: completion)
      }
    }
  }
  
  private func cache(items: [FeedItem], completion: @escaping (Error?) -> Void) {
    store.insert(items: items, timeStamp: currentDate(), completion: { [weak self] cacheInsertionError in
      guard self != nil else { return }
      completion(cacheInsertionError)
    })
  }
}

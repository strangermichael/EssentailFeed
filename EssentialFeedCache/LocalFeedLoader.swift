//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2023/12/29.
//

import Foundation
import EssentialFeed

public final class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
}
  
extension LocalFeedLoader: FeedCache {
  public typealias SaveResult = FeedCache.SaveResult
  
  public func save(items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
    store.deleteCachedFeed { [weak self] cacheDeletionError in
      guard let this = self else { return }
      if let cacheDeletionError = cacheDeletionError {
        completion(cacheDeletionError) //only call back once, since will call back once get insert result
      } else {
        this.cache(items: items, completion: completion)
      }
    }
  }
  
  private func cache(items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
    store.insert(items: items.toLocal(), timestamp: currentDate(), completion: { [weak self] result in
      guard self != nil else { return }
      switch result {
      case .success:
        completion(nil)
      case let .failure(cacheInsertionError):
        completion(cacheInsertionError)
      }
    })
  }
}

extension LocalFeedLoader: FeedLoader {
  public typealias LoadResult = FeedLoader.Result
  
  public func load(completion: @escaping (LoadResult) -> Void) {
    store.retrieve { [weak self] result in
      guard let this = self else {
        return
      }
      switch result {
      case let .failure(error):
        completion(.failure(error))
      case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: this.currentDate()):
        completion(.success(cache.feed.toModels()))
      case .success(.some), .success(.none):
        completion(.success([]))
      }
    }
  }
}
  
extension LocalFeedLoader {
  public func validateCache() {
    store.retrieve { [weak self] result in
      guard let this = self else {
        return
      }
      switch result {
      case .failure:
        this.store.deleteCachedFeed { _ in }
      case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: this.currentDate()):
        this.store.deleteCachedFeed { _ in }
      case .success(.some), .success(.none):
        break
      }
    }
  }
}

private extension Array where Element == FeedImage {
  func toLocal() -> [LocalFeedImage] {
    map {
      LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
  }
}

private extension Array where Element == LocalFeedImage {
  func toModels() -> [FeedImage] {
    map {
      FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
    }
  }
}

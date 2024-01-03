//
//  LocalFeedLoader.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/29.
//

import Foundation

private final class FeedCachePolicy {
  private static let calendar = Calendar(identifier: .gregorian)
  
  private static var maxCacheAgeInDays: Int {
    7
  }
  
  static func validate(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
      return false
    }
    return date < maxCacheAge
  }
}

public final class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
}
  
extension LocalFeedLoader {
  public typealias SaveResult = Error?
  
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
    store.insert(items: items.toLocal(), timeStamp: currentDate(), completion: { [weak self] cacheInsertionError in
      guard self != nil else { return }
      completion(cacheInsertionError)
    })
  }
}

extension LocalFeedLoader {
  public typealias LoadResult = LoadFeedResult
  
  public func load(completion: @escaping (LoadResult) -> Void) {
    store.retrieve { [weak self] result in
      guard let this = self else {
        return
      }
      switch result {
      case let .failure(error):
        completion(.failure(error))
      case let .found(feed, timestamp) where FeedCachePolicy.validate(timestamp, against: this.currentDate()):
        completion(.success(feed.toModels()))
      case .found, .empty:
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
      case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: this.currentDate()):
        this.store.deleteCachedFeed { _ in }
      case .found, .empty:
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

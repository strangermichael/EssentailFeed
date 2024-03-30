//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2023/12/29.
//

import Foundation

public struct CachedFeed {
  public let feed: [LocalFeedImage]
  public let timestamp: Date
  
  public init(feed: [LocalFeedImage], timestamp: Date) {
    self.feed = feed
    self.timestamp = timestamp
  }
}

public protocol FeedStore {
  typealias DeletionResult = Error?
  typealias DeletionCompletion = (DeletionResult) -> Void
  
  typealias InsertionResult = Result<Void, Error>
  typealias InsertionCompletion = (InsertionResult) -> Void
  
  typealias RetrievalResult = Result<CachedFeed?, Error>
  typealias RetrievalCompletion = (RetrievalResult) -> Void
  
  ///The completion handler can be invoked in any thread
  ///Clients are responsible to dispacth to appropriate thread
  func deleteCachedFeed(completion: @escaping DeletionCompletion)
  ///The completion handler can be invoked in any thread
  ///Clients are responsible to dispacth to appropriate thread
  func insert(items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
  ///The completion handler can be invoked in any thread
  ///Clients are responsible to dispacth to appropriate thread
  func retrieve(completion: @escaping RetrievalCompletion)
}

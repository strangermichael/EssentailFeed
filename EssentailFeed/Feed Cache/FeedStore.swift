//
//  FeedStore.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/29.
//

import Foundation

public enum RetrieveCachedFeedResult {
  case empty
  case found(feed: [LocalFeedImage], timeStamp: Date)
  case failure(Error)
}

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
  
  ///The completion handler can be invoked in any thread
  ///Clients are responsible to dispacth to appropriate thread
  func deleteCachedFeed(completion: @escaping DeletionCompletion)
  ///The completion handler can be invoked in any thread
  ///Clients are responsible to dispacth to appropriate thread
  func insert(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
  ///The completion handler can be invoked in any thread
  ///Clients are responsible to dispacth to appropriate thread
  func retrieve(completion: @escaping RetrievalCompletion)
}

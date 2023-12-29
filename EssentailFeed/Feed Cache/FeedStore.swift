//
//  FeedStore.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/29.
//

import Foundation

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  
  func deleteCachedFeed(completion: @escaping DeletionCompletion)
  func insert(items: [FeedItem], timeStamp: Date, completion: @escaping InsertionCompletion)
}

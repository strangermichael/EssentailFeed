//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2023/12/31.
//

import Foundation
import EssentialFeed
import EssentialFeedCache

class FeedStoreSpy: FeedStore {
  enum ReceivedMessage: Equatable {
    case deleteCachedFeed
    case insert([LocalFeedImage], Date)
    case retrieval
  }
  
  private(set) var receivedMessages = [ReceivedMessage]()
  private var deletionCompletions: [DeletionCompletion] = []
  private var insertionCompletions: [InsertionCompletion] = []
  private var retrievalCompletions: [RetrievalCompletion] = []
  
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedFeed)
  }
  
  func completDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](.failure(error))
  }
  
  func completInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](.success(()))
  }
  
  func insert(items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(items, timestamp))
  }
  
  func complelteRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](.failure(error))
  }
  
  func complelteRetrievalWithEmptyCache(at index: Int = 0) {
    retrievalCompletions[index](.success(.none))
  }
  
  func complelteRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
    retrievalCompletions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
  }
  
  func retrieve(completion: @escaping RetrievalCompletion) {
    retrievalCompletions.append(completion)
    receivedMessages.append(.retrieval)
  }
}

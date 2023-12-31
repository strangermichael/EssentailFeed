//
//  FeedStoreSpy.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/12/31.
//

import Foundation
import EssentailFeed

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
  
  func completInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }
  
  func completInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }
  
  func insert(items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(items, timeStamp))
  }
  
  func complelteRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](error)
  }
  
  func retrieve(completion: @escaping RetrievalCompletion) {
    retrievalCompletions.append(completion)
    receivedMessages.append(.retrieval)
  }
}

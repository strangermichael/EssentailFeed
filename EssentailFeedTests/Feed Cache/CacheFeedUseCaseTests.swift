//
//  CacheFeedUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/12/28.
//

import XCTest
import EssentailFeed

class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
  
  init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  func save(items: [FeedItem]) {
    store.deleteCachedFeed { [weak self] error in
      guard let this = self else { return }
      if error == nil {
        this.store.insert(items: items, timeStamp: this.currentDate())
      }
    }
  }
}

class FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  enum ReceivedMessage: Equatable {
    case deleteCachedFeed
    case insert([FeedItem], Date)
  }
  
  private(set) var receivedMessages = [ReceivedMessage]()
  private var deletionCompletions: [DeletionCompletion] = []
  
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
  
  func insert(items: [FeedItem], timeStamp: Date) {
    receivedMessages.append(.insert(items, timeStamp))
  }
}

final class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageSToreUponCreation() {
    let (_, store) = makeSUT()
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_save_requestCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    sut.save(items: items)
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    sut.save(items: items)
    store.completDeletion(with: anyNSError())
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
    
  func test_save_requestCacheInsertionWithTimeStampOnSuccessfulDeletion() {
    let timeStamp = Date() //use injection to avoid timestamp different
    let (sut, store) = makeSUT(currentDate: { timeStamp })
    let items = [uniqueItem(), uniqueItem()]
    sut.save(items: items)
    store.completDeletionSuccessfully()
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timeStamp)])
  }
  
  //Helper
  private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(store)
    return (sut, store)
  }
  
  private func uniqueItem() -> FeedItem {
    FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  func anyURL() -> URL {
    URL(string: "http://url.com")!
  }
  
  func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
  }
}

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
  init(store: FeedStore) {
    self.store = store
  }
  
  func save(items: [FeedItem]) {
    store.deleteCachedFeed { [weak self] error in
      if error == nil {
        self?.store.insert(items: items)
      }
    }
  }
}

class FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  var deleteCacheFeedCallCount = 0
  var insertCallCount = 0
  private var deletionCompletions: [DeletionCompletion] = []
  
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deleteCacheFeedCallCount += 1
    deletionCompletions.append(completion)
  }
  
  func completDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func insert(items: [FeedItem]) {
    insertCallCount += 1
  }
}

final class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCacheUponCreation() {
    let (_, store) = makeSUT()
    XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
  }
  
  func test_save_requestCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    sut.save(items: items)
    XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    sut.save(items: items)
    store.completDeletion(with: anyNSError())
    XCTAssertEqual(store.insertCallCount, 0)
  }
  
  func test_save_requestCacheInsertionOnSuccessfulDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    sut.save(items: items)
    store.completDeletionSuccessfully()
    XCTAssertEqual(store.insertCallCount, 1)
  }
  
  //Helper
  private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
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

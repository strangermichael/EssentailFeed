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
    store.deleteCachedFeed()
  }
}

class FeedStore {
  var deleteCacheFeedCallCount = 0
  
  func deleteCachedFeed() {
    deleteCacheFeedCallCount += 1
  }
}

final class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCacheUponCreation() {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
  }
  
  func test_save_requestCacheDeletion() {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    let items = [uniqueItem(), uniqueItem()]
    sut.save(items: items)
    XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
  }
  
  private func uniqueItem() -> FeedItem {
    FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  func anyURL() -> URL {
    URL(string: "http://url.com")!
  }
}

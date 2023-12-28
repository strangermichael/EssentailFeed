//
//  CacheFeedUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/12/28.
//

import XCTest

class LocalFeedLoader {
  private let store: FeedStore
  init(store: FeedStore) {
    self.store = store
  }
}

class FeedStore {
  var deleteCacheFeedCallCount = 0
  
}

final class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCacheUponCreation() {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
  }
  
  
}

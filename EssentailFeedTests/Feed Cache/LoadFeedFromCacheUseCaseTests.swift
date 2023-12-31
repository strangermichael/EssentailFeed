//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/12/31.
//

import XCTest
import EssentailFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageSToreUponCreation() {
    let (_, store) = makeSUT()
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  //Helper
  private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(store)
    return (sut, store)
  }
}

//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2024/1/1.
//

import XCTest
import EssentailFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    XCTAssertTrue(store.receivedMessages.isEmpty)
  }
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(store)
    return (sut, store)
  }
}

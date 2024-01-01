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
  
  func test_validateCache_deletesCacheOnRetrievalError() {
    let (sut, store) = makeSUT()
    sut.validateCache()
    store.complelteRetrieval(with: anyNSError())
    XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
  }
  
  func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
    let (sut, store) = makeSUT()
    sut.validateCache()
    store.complelteRetrievalWithEmptyCache()
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCachee() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    sut.validateCache()
    store.complelteRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimeStamp)
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  func test_validateCache_doesDeleteCacheOnSevenDaysOldCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
    sut.validateCache()
    store.complelteRetrieval(with: feed.local, timestamp: sevenDaysOldTimeStamp)
    XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
  }
  
  func test_validateCache_doesDeleteCacheOnMoreThanSevenDaysOldCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let moreThansevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
    sut.validateCache()
    store.complelteRetrieval(with: feed.local, timestamp: moreThansevenDaysOldTimeStamp)
    XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
  }
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(store)
    return (sut, store)
  }
}

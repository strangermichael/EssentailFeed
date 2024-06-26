//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/1/1.
//

import XCTest
import EssentialFeed
import EssentialFeedCache

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
  
  func test_validateCache_doesNotDeleteCacheOnNonExpiredCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let nonExpiredtimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
    sut.validateCache()
    store.complelteRetrieval(with: feed.local, timestamp: nonExpiredtimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  func test_validateCache_doesDeleteCacheOnCacheExpiration() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let expirationtimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
    sut.validateCache()
    store.complelteRetrieval(with: feed.local, timestamp: expirationtimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
  }
  
  func test_validateCache_doesDeleteCacheOnExpiredCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let expiredtimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
    sut.validateCache()
    store.complelteRetrieval(with: feed.local, timestamp: expiredtimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
  }
  
  func test_validateCache_doesDeleteCacheAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    sut?.validateCache()
    sut = nil
    store.complelteRetrieval(with: anyNSError())
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(store)
    return (sut, store)
  }
}

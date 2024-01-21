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
  
  func test_load_requestsCacheRetrieval() {
    let (sut, store) = makeSUT()
    sut.load { _ in }
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  func test_load_failsOnRetrievalError() {
    let (sut, store) = makeSUT()
    let retrievalError = anyNSError()
    expect(sut, toCompletWith: .failure(retrievalError)) {
      store.complelteRetrieval(with: retrievalError)
    }
  }
  
  func test_load_deliversNoImagesOnEmptyCache() {
    let (sut, store) = makeSUT()
    expect(sut, toCompletWith: .success([])) {
      store.complelteRetrievalWithEmptyCache()
    }
  }
  
  func test_load_deliversCachedImagesOnNonExpiredCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let nonExpiredtimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
    expect(sut, toCompletWith: .success(feed.models)) {
      store.complelteRetrieval(with: feed.local, timestamp: nonExpiredtimestamp)
    }
  }
  
  func test_load_deliversNoImagesOnCacheExpiration() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let expirationtimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
    expect(sut, toCompletWith: .success([])) {
      store.complelteRetrieval(with: feed.local, timestamp: expirationtimestamp)
    }
  }
  
  func test_load_deliversNoImagesOnExpiredCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let expiredtimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
    expect(sut, toCompletWith: .success([])) {
      store.complelteRetrieval(with: feed.local, timestamp: expiredtimestamp)
    }
  }
  
  func test_load_hasNoSideEffectOnRetrievalError() {
    let (sut, store) = makeSUT()
    sut.load { _ in }
    store.complelteRetrieval(with: anyNSError())
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  func test_load_hasNoSideEffectOnEmptyCache() {
    let (sut, store) = makeSUT()
    sut.load { _ in }
    store.complelteRetrievalWithEmptyCache()
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  func test_load_dhasNoSideEffectsOnNonExpiredCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let nonExpiredtimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
    sut.load { _ in }
    store.complelteRetrieval(with: feed.local, timestamp: nonExpiredtimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  func test_load_hasNoSideEffectOnCacheExpiration() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let expirationtimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
    sut.load { _ in }
    store.complelteRetrieval(with: feed.local, timestamp: expirationtimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  func test_load_hasNoSideEffectOnExpiredCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let expiredtimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
    sut.load { _ in }
    store.complelteRetrieval(with: feed.local, timestamp: expiredtimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieval])
  }
  
  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    var receivedResults: [LocalFeedLoader.LoadResult] = []
    sut?.load(completion: { receivedResults.append($0) })
    sut = nil
    store.complelteRetrievalWithEmptyCache()
    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  //Helper
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(store)
    return (sut, store)
  }
  
  private func expect(_ sut: LocalFeedLoader, toCompletWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "wait for load completion")
    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedImages), .success(expectedImages)):
        XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
      case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
      default:
        XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    }
    action()
    wait(for: [exp], timeout: 1.0)
  }
}

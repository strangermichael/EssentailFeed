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
    let exp = expectation(description: "wait for load completion")
    let retrievalError = anyNSError()
    var receivedError: Error?
    sut.load { result in
      switch result {
      case let .failure(error):
        receivedError = error
      default:
        XCTFail("Expected failure, got \(result) instead")
      }
      exp.fulfill()
    }
    store.complelteRetrieval(with: retrievalError)
    wait(for: [exp], timeout: 1.0)
    XCTAssertEqual(receivedError as NSError?, retrievalError)
  }
  
//  func test_load_deliversNoImagesOnEmptyCache() {
//    let (sut, store) = makeSUT()
//    let exp = expectation(description: "wait for load completion")
//    var receivedImages: [FeedImage]?
//    sut.load { error in
//      receivedError = error
//      exp.fulfill()
//    }
//    store.complelteRetrieval(with: retrievalError)
//    wait(for: [exp], timeout: 1.0)
//    XCTAssertEqual(receivedError as NSError?, retrievalError)
//  }
  
  //Helper
  private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(store)
    return (sut, store)
  }
  
  func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
  }
}

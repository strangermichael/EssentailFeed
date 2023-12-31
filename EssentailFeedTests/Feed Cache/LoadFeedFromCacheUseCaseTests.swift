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
  
  func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
  }
}

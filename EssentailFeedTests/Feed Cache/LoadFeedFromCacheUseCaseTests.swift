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
  
  func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    expect(sut, toCompletWith: .success(feed.models)) {
      store.complelteRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimeStamp)
    }
  }
  
  func test_load_deliversNoImagesOnSevenDaysOldCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
    expect(sut, toCompletWith: .success([])) {
      store.complelteRetrieval(with: feed.local, timestamp: sevenDaysOldTimeStamp)
    }
  }
  
  func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
    let fixedCurrentDate = Date()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let feed = uniqueImageFeed()
    let moreThansevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
    expect(sut, toCompletWith: .success([])) {
      store.complelteRetrieval(with: feed.local, timestamp: moreThansevenDaysOldTimeStamp)
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
  
  private func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func anyURL() -> URL {
    URL(string: "http://url.com")!
  }
  
  private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let model = [uniqueImage(), uniqueImage()]
    let local = model.map {
      LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
    return (model, local)
  }
}


private extension Date {
  //some days may not have 24 hours
  func adding(days: Int) -> Date {
    Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: Double) -> Date {
    self + seconds
  }
}

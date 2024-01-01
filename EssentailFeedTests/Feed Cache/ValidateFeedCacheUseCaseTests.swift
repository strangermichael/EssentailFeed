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
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
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

private extension Date {
  //some days may not have 24 hours
  func adding(days: Int) -> Date {
    Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: Double) -> Date {
    self + seconds
  }
}

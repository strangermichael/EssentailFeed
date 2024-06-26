//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/1/16.
//

import XCTest
import EssentialFeed
import EssentialFeedCache

extension FeedStoreSpecs where Self: XCTestCase {

  func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }

  func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
  }

  func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    insert(items: feed, timestamp: timestamp, to: sut)

    expect(sut, toRetrieve: .success(.some(CachedFeed(feed: feed, timestamp: timestamp))), file: file, line: line)
  }

  func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    insert(items: feed, timestamp: timestamp, to: sut)

    expect(sut, toRetrieveTwice: .success(.some(CachedFeed(feed: feed, timestamp: timestamp))), file: file, line: line)
  }

  func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let insertionError = insert(items: uniqueImageFeed().local, timestamp: Date(), to: sut)

    XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
  }

  func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert(items: uniqueImageFeed().local, timestamp: Date(), to: sut)

    let insertionError = insert(items: uniqueImageFeed().local, timestamp: Date(), to: sut)

    XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
  }

  func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert(items: uniqueImageFeed().local, timestamp: Date(), to: sut)

    let latestFeed = uniqueImageFeed().local
    let latesttimestamp = Date()
    insert(items: latestFeed, timestamp: latesttimestamp, to: sut)

    expect(sut, toRetrieve: .success(.some(CachedFeed(feed: latestFeed, timestamp: latesttimestamp))), file: file, line: line)
  }

  func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
  }

  func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    deleteCache(from: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }

  func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert(items: uniqueImageFeed().local, timestamp: Date(), to: sut)

    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
  }

  func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert(items: uniqueImageFeed().local, timestamp: Date(), to: sut)

    deleteCache(from: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }

  func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    var completedOperationsInOrder = [XCTestExpectation]()

    let op1 = expectation(description: "Operation 1")
    sut.insert(items: uniqueImageFeed().local, timestamp: Date()) { _ in
      completedOperationsInOrder.append(op1)
      op1.fulfill()
    }

    let op2 = expectation(description: "Operation 2")
    sut.deleteCachedFeed { _ in
      completedOperationsInOrder.append(op2)
      op2.fulfill()
    }

    let op3 = expectation(description: "Operation 3")
    sut.insert(items: uniqueImageFeed().local, timestamp: Date()) { _ in
      completedOperationsInOrder.append(op3)
      op3.fulfill()
    }

    waitForExpectations(timeout: 5.0)

    XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
  }

}

extension FeedStoreSpecs where Self: XCTestCase {
  @discardableResult
  func insert(items: [LocalFeedImage], timestamp: Date, to sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache retrieval")
    var insertionError: Error?
    sut.insert(items: items, timestamp: timestamp) { result in
      switch result {
      case .success:
        break
      case let .failure(error):
        insertionError = error
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return insertionError
  }
  
  @discardableResult
  func deleteCache(from sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache deleteion")
    var deletionError: Error?
    sut.deleteCachedFeed { receivedDeletionError in
      deletionError = receivedDeletionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 5.0)
    return deletionError
  }
  
  func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retriveval")
    sut.retrieve { retrievedResult in
      switch (retrievedResult, expectedResult) {
      case (.success(.none), .success(.none)),
           (.failure, .failure):
        break
      case let (.success(foundedCache), .success(retrievedCache)):
        XCTAssertEqual(foundedCache?.feed, retrievedCache?.feed)
        XCTAssertEqual(retrievedCache?.timestamp, retrievedCache?.timestamp)
      default:
        XCTFail("Expected to retrieve \(expectedResult), but got \(retrievedResult) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
}

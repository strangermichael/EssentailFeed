//
//  EssentailFeedCacheIntegrationTests.swift
//  EssentailFeedCacheIntegrationTests
//
//  Created by Shengjun Xia on 2024/1/20.
//

import XCTest
import EssentailFeed

final class EssentailFeedCacheIntegrationTests: XCTestCase {
  func test_load_deliversNoItemsOnEmptyCache() {
    let sut = makeSUT()
    let exp = expectation(description: "wait for load completion")
    sut.load { result in
      switch result {
      case let .success(imageFeed):
        XCTAssertEqual(imageFeed, [], "Expected empty feed")
      case let .failure(error):
        XCTFail("Expected successful feed result, got \(error) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func testSpecificStoreURL() -> URL {
    cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }
  
  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
}

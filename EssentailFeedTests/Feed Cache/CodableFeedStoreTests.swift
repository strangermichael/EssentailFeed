//
//  CodableFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2024/1/13.
//

import XCTest
import EssentailFeed

class CodableFeedStore {
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    completion(.empty)
  }
}

final class CodableFeedStoreTests: XCTestCase {
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = CodableFeedStore()
    let exp = expectation(description: "wait for cache retrieval")
    sut.retrieve { result in
      switch result {
      case .empty:
        break
      default:
        XCTFail("Expected empty, got \(result) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  
}

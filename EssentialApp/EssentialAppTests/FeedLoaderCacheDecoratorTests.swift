//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/25.
//

import XCTest
import EssentialFeed

class FeedLoaderCacheDecorator: FeedLoader {
  private let decoratee: FeedLoader
  
  init(decoratee: FeedLoader) {
    self.decoratee = decoratee
  }
  
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load(completion: completion)
  }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase {
  
  func test_load_deliversFeedOnLoaderSuccess() {
    let feed = uniqueFeed()
    let loader = LoaderStub(result: .success(feed))
    let sut = FeedLoaderCacheDecorator(decoratee: loader)
    expect(sut, toCompleteWith: .success(feed))
  }
  
  //MARK: - Helpers
  private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedFeed), .success(expectedFeed)):
        XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
      case (.failure, .failure):
        break
      default:
        XCTFail("Expected \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private class LoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
      self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completion(result)
    }
  }
}

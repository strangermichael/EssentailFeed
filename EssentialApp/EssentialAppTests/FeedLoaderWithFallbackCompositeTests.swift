//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/23.
//

import XCTest
import EssentialFeed


class FeedLoaderWithFallbackComposite: FeedLoader {
  let primary: FeedLoader
  let fallback: FeedLoader
  
  init(primary: FeedLoader, fallback: FeedLoader) {
    self.primary = primary
    self.fallback = fallback
  }
  
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    primary.load { [weak self] result in
      switch result {
      case .success:
        completion(result)
      case .failure:
        self?.fallback.load(completion: completion)
      }
    }
  }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {
  
  func test_load_deliversRemoteFeedOnRemoteSuccess() {
    let primayFeed = uniqueFeed()
    let fallBackFeed = uniqueFeed()
    let sut = makeSUT(primaryResult: .success(primayFeed), fallbackResult: .success(fallBackFeed))
    expect(sut, toCompleteWith: .success(primayFeed))
  }
  
  func test_load_deliversFallbackFeedOnPrimaryFailure() {
    let fallBackFeed = uniqueFeed()
    let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallBackFeed))
    expect(sut, toCompleteWith: .success(fallBackFeed))
  }
  
  //MARK: - Helpers
  private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
    let primaryLoder = LoaderStub(result: primaryResult)
    let fallbackLoader = LoaderStub(result: fallbackResult)
    let sut = FeedLoaderWithFallbackComposite(primary: primaryLoder, fallback: fallbackLoader)
    trackForMemoryLeaks(primaryLoder, file: file, line: line)
    trackForMemoryLeaks(fallbackLoader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
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
  
  func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
  }
  
  private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
    }
  }

  
  func uniqueFeed() -> [FeedImage] {
    [
      FeedImage(id: UUID(), description: "any", location: "any", imageURL: URL(string: "http://any-url.com")!)
    ]
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

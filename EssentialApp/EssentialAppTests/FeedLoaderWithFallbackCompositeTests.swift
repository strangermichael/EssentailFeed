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
    primary.load(completion: completion)
  }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

  func test_load_deliversRemoteFeedOnRemoteSuccess() {
    let primayFeed = uniqueFeed()
    let fallBackFeed = uniqueFeed()
    
    let primaryLoder = LoaderStub(result: .success(primayFeed))
    let fallbackLoader = LoaderStub(result: .success(fallBackFeed))
    
    let sut = FeedLoaderWithFallbackComposite(primary: primaryLoder, fallback: fallbackLoader)
    let exp = expectation(description: "Wait for load completion")
    sut.load { result in
      switch result {
      case let .success(receivedFeed):
        XCTAssertEqual(receivedFeed, primayFeed)
      case .failure:
        XCTFail("Expected successful load feed result, git \(result) intead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
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

//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/25.
//

import XCTest
import EssentialFeed

protocol FeedCache {
  typealias SaveResult = Error?
  
  func save(items: [FeedImage], completion: @escaping (SaveResult) -> Void)
}

class FeedLoaderCacheDecorator: FeedLoader {
  private let decoratee: FeedLoader
  
  init(decoratee: FeedLoader, cache: FeedCache) {
    self.decoratee = decoratee
  }
  
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load(completion: completion)
  }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
  
  func test_load_deliversFeedOnLoaderSuccess() {
    let feed = uniqueFeed()
    let sut = makeSUT(loaderResult: .success(feed))
    expect(sut, toCompleteWith: .success(feed))
  }
  
  func test_load_deliversErrorOnLoaderFailure() {
    let sut = makeSUT(loaderResult: .failure(anyNSError()))
    expect(sut, toCompleteWith: .failure(anyNSError()))
  }
  
  func test_load_cachesLoadedFeedOnLoaderSuccess() {
    let cache = CacheSpy()
    let feed = uniqueFeed()
    let sut = makeSUT(loaderResult: .success(feed), cache: cache)
    sut.load { _ in }
    XCTAssertEqual(cache.messages, [.save(feed)])
  }
  
  private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> FeedLoader {
    let loader = FeedLoaderStub(result: loaderResult)
    let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
    trackForMemoryLeaks(loader)
    trackForMemoryLeaks(sut)
    return sut
  }
  
  private class CacheSpy: FeedCache {
    private(set) var messages: [Message] = []
    
    enum Message: Equatable {
      case save([FeedImage])
    }
    
    func save(items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
      messages.append(.save(items))
      completion(nil)
    }
  }
}

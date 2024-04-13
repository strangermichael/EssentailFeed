//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/23.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
  
  func test_load_deliversPrimaryFeedOnPrimarySuccess() {
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
  
  func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
    let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
    expect(sut, toCompleteWith: .failure(anyNSError()))
  }
  
  //MARK: - Helpers
  private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
    let primaryLoder = FeedLoaderStub(result: primaryResult)
    let fallbackLoader = FeedLoaderStub(result: fallbackResult)
    let sut = FeedLoaderWithFallbackComposite(primary: primaryLoder, fallback: fallbackLoader)
    trackForMemoryLeaks(primaryLoder, file: file, line: line)
    trackForMemoryLeaks(fallbackLoader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
}

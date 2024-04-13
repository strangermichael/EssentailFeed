//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/1/16.
//

import XCTest
import EssentialFeed
import EssentialFeedCache

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
  func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let insertionError = insert(items: uniqueImageFeed().local, timestamp: Date(), to: sut)

    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
  }

  func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert(items: uniqueImageFeed().local, timestamp: Date(), to: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }
}

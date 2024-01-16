//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2024/1/16.
//

import XCTest
import EssentailFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
  func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    let insertionError = insert(items: uniqueImageFeed().local, timeStamp: Date(), to: sut)

    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
  }

  func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    insert(items: uniqueImageFeed().local, timeStamp: Date(), to: sut)

    expect(sut, toRetrieve: .empty, file: file, line: line)
  }
}

//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2024/1/16.
//

import XCTest
import EssentailFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
  func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)

    XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
  }

  func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    deleteCache(from: sut)

    expect(sut, toRetrieve: .empty, file: file, line: line)
  }
}

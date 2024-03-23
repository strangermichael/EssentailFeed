//
//  SharedTestHelper.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/23.
//

import XCTest

func anyNSError() -> NSError {
  NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  URL(string: "http://url.com")!
}

func anyData() -> Data {
  Data("any data".utf8)
}


public extension XCTestCase {
  func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
    }
  }
}

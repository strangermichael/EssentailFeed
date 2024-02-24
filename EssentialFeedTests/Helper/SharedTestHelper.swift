//
//  SharedTestHelper.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/1/1.
//

import Foundation

func anyNSError() -> NSError {
  NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  URL(string: "http://url.com")!
}

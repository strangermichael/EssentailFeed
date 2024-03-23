//
//  SharedTestHelper.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/23.
//

import Foundation

func anyNSError() -> NSError {
  NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  URL(string: "http://url.com")!
}

func anyData() -> Data {
  Data("any data".utf8)
}

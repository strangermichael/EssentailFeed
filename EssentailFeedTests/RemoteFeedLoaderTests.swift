//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/10/19.
//

import XCTest

class RemoteFeedLoader {
  
}

class HTTPClient {
  var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init() {
    let _ = RemoteFeedLoader()
    let client = HTTPClient()
    XCTAssertNil(client.requestedURL)
  }
  
}

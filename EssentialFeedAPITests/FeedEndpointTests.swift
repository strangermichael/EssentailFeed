//
//  FeedEndpointTests.swift
//  EssentialFeedAPITests
//
//  Created by Shengjun Xia on 2024/4/22.
//

import XCTest
import EssentialFeedAPI

final class FeedEndpointTests: XCTestCase {
  
  func test_feed_endpointURL() {
    let baseURL = URL(string: "http://base-url.com")!
    let received = FeedEndpoint.get.url(baseURL: baseURL)!
    XCTAssertEqual(received.scheme, "http", "scheme")
    XCTAssertEqual(received.host, "base-url.com", "host")
    XCTAssertEqual(received.path, "/v1/feed", "path")
    XCTAssertEqual(received.query, "limit=10", "query")
  }
  
}

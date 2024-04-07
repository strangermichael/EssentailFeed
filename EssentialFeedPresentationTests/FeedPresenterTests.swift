//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/2/25.
//

import XCTest
import EssentialFeed
import EssentialFeedPresentation

class FeedPresenterTests: XCTestCase {
  
  func test_title_isLocalized() {
    XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
  }
  
  func test_map_createsViewModel() {
    let feed = uniqueFeedImages()
    let viewModel = FeedPresenter.map(feed)
    XCTAssertEqual(viewModel.feed, feed)
  }
  
  private func localized(_ key: String, table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
    let table = table
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    if value == key {
      XCTFail("Missing localized string for key: \(key)", file: file, line: line)
    }
    return value
  }
}

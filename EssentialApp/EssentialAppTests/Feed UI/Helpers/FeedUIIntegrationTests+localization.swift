//
//  FeedViewControllerTest+localization.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/2/24.
//

import XCTest
import EssentialFeediOS
import EssentialFeed


extension FeedUIIntegrationTests {
  func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    if value == key {
      XCTFail("Missing localized string for key: \(key)", file: file, line: line)
    }
    return value
  }
}

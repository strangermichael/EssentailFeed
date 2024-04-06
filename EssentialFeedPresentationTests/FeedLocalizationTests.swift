//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/2/24.
//

import XCTest
import EssentialFeed
import EssentialFeedPresentation

final class FeedLocalizationTests: XCTestCase {
  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    assertLocalizedKeyAndValuesExist(in: bundle, table)
  }
}

//
//  SharedLocalizationTests.swift
//  EssentialFeedPresentationTests
//
//  Created by Shengjun Xia on 2024/4/6.
//

import XCTest
import EssentialFeed
import EssentialFeedPresentation

final class SharedLocalizationTests: XCTestCase {
  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "Shared"
    let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
    assertLocalizedKeyAndValuesExist(in: bundle, table)
  }
  
  private class DummyView: ResourceView {
    func display(_ viewModel: Any) { }
  }
}

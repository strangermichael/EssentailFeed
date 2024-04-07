//
//  ImageCommentLocalizationTests.swift
//  EssentialFeedPresentationTests
//
//  Created by Shengjun Xia on 2024/4/7.
//

import XCTest
import EssentialFeedPresentation

final class ImageCommentLocalizationTests: XCTestCase {
  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "ImageComments"
    let bundle = Bundle(for: ImageCommentsPresenter.self)
    assertLocalizedKeyAndValuesExist(in: bundle, table)
  }
  
}

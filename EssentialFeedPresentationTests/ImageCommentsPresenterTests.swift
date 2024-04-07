//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedPresentationTests
//
//  Created by Shengjun Xia on 2024/4/7.
//

import XCTest
import EssentialFeedPresentation
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {
  func test_title_isLocalized() {
    XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
  }
  
  func test_map_createsViewModel() {
    let now = Date()
    let calendar = Calendar(identifier: .gregorian)
    let locale = Locale(identifier: "en_US_POSIX")
    let comments = [
      ImageComment(id: UUID(), message: "a message", createdAt: now.adding(minutes: -5), userName: "a user name"),
      ImageComment(id: UUID(), message: "another message", createdAt: now.adding(days: -1, calendar: calendar), userName: "another user name")
    ]
    let viewModel = ImageCommentsPresenter.map(comments, currentDate: now, calendar: calendar, locale: locale)
    XCTAssertEqual(viewModel.comments, [
      ImageCommentViewModel(
        message: "a message",
        date: "5 minutes ago",
        username: "a user name"
      ),
      
      ImageCommentViewModel(
        message: "another message",
        date: "1 day ago",
        username: "another user name"
      )
    ])
  }
  
  private func localized(_ key: String, table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
    let table = "ImageComments"
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    if value == key {
      XCTFail("Missing localized string for key: \(key)", file: file, line: line)
    }
    return value
  }
}

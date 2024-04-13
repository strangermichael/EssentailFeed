//
//  SharedTestHelper.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/23.
//

import XCTest
import EssentialFeed
import EssentialFeedPresentation

func anyNSError() -> NSError {
  NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  URL(string: "http://url.com")!
}

func anyData() -> Data {
  Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
  [
    FeedImage(id: UUID(), description: "any", location: "any", imageURL: URL(string: "http://any-url.com")!)
  ]
}

public extension XCTestCase {
  func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
    }
  }
}

private class DummyView: ResourceView {
  func display(_ viewModel: Any) { }
}

var loadError: String {
  LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
  FeedPresenter.title
}

var commentsTitle: String {
  ImageCommentsPresenter.title
}

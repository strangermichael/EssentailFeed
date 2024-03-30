//
//  FeedUIIntegrationTests+Assertion.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/2/24.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
  func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
    //reload data不会立刻更新布局，会在下一个layout cycle更新，所以运行测试的时候让它强制现在更新
    sut.tableView.layoutIfNeeded()
    RunLoop.main.run(until: Date())
    guard sut.numberOfRenderedFeedImageViews() == feed.count else {
      return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
    }
    feed.enumerated().forEach { index, image in
      assertThat(sut, hasViewConfiguredFor: image, at: index)
    }
  }
  
  func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
    let view = sut.feedImageView(at: index)
    guard let cell = view as? FeedImageCell else {
      XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
      return
    }
    let shouldLocationBeVisible = image.location != nil
    XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected isShowingLocation to be \(shouldLocationBeVisible) for image view at index \(index)", file: file, line: line)
    XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image view at index \(index)", file: file, line: line)
    XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index \(index)", file: file, line: line)
  }
}

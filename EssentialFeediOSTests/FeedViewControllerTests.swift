//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/1/30.
//

import XCTest
import UIKit
import EssentailFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
  
  func test_loadFeedActions_requestFeedFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadCallCount, 1, "Expected no loading requests once view is loaded")
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading requests once usee initiates a load")
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading requests once usee initiates another load")
  }
  
  func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()
    XCTAssertEqual(sut.isShowingLoadingUI, true, "Expected show loading once view is loaded")
    loader.completFeedLoading(at: 0)
    XCTAssertEqual(sut.isShowingLoadingUI, false, "Expected no loading once loader is completed")
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(sut.isShowingLoadingUI, true, "Expected show loading once user initiates a reload")
    loader.completFeedLoading(at: 1)
    XCTAssertEqual(sut.isShowingLoadingUI, false, "Expected no loading once user initiated loading is completed")
  }
  
  func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
    let image0 = makeImage(description: "a description", location: "a location")
    let image1 = makeImage(description: nil, location: "another location")
    let image2 = makeImage(description: "another description", location: nil)
    let image3 = makeImage(description: nil, location: "nil")
    
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()
    assertThat(sut, isRendering: [])
    
    loader.completFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRendering: [image0])
    
    sut.simulateUserInitiatedFeedReload()
    loader.completFeedLoading(with: [image0, image1, image2, image3], at: 1)
    assertThat(sut, isRendering: [image0, image1, image2, image3])
  }
  
  func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
    let image0 = makeImage()
    let (sut, loader) = makeSUT()
    
    sut.loadViewIfNeeded()
    loader.completFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRendering: [image0])
    
    sut.simulateUserInitiatedFeedReload()
    loader.completFeedloadingWithError(at: 1)
    assertThat(sut, isRendering: [image0])
  }
  
  //MARK: - Helpers
  class LoaderSpy: FeedLoader {
    var loadCallCount: Int {
      completions.count
    }
    private var completions: [(FeedLoader.Result) -> Void] = []
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completions.append(completion)
    }
    
    func completFeedLoading(with images: [FeedImage] = [], at index: Int) {
      completions[index](.success(images))
    }
    
    func completFeedloadingWithError(at index: Int) {
      completions[index](.failure(anyNSError()))
    }
  }
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }
  
  private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
    FeedImage(id: UUID(), description: description, location: location, imageURL: url)
  }
  
  private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
    guard sut.numberOfRenderedFeedImageViews() == feed.count else {
      return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
    }
    feed.enumerated().forEach { index, image in
      assertThat(sut, hasViewConfiguredFor: image, at: index)
    }
  }
  
  private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
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

private extension FeedViewController {
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }
  
  var isShowingLoadingUI: Bool {
    refreshControl?.isRefreshing == true
  }
  
  func numberOfRenderedFeedImageViews() -> Int {
    tableView.numberOfRows(inSection: feedImagesSection)
  }
  
  private var feedImagesSection: Int {
    0
  }
  
  func feedImageView(at row: Int) -> UITableViewCell? {
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
}

private extension FeedImageCell {
  var isShowingLocation: Bool {
    return !locationContainer.isHidden
  }
  
  var locationText: String? {
    locationLabel.text
  }
  
  var descriptionText: String? {
    descriptionLabel.text
  }
}

private extension UIRefreshControl {
  //no need to actually trigger the UI, just need to trigger the action UI binds
  func simulatePullToRefresh() {
    allTargets.forEach({ target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ actionString in
        (target as NSObject).perform(Selector(actionString))
      })
    })
  }
}

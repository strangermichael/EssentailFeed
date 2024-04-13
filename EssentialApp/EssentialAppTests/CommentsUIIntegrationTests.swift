//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/4/13.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class CommentsUIIntegrationTests: FeedUIIntegrationTests {
  func test_commentView_hasTitle() {
    let (sut, _) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.title, commentsTitle)
  }
  
  func test_loadCommentsActions_requestCommentsFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view appears")
    sut.simulateAppearance()
    XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no loading requests once view appears")
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading requests once usee initiates a load")
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected a third loading requests once usee initiates another load")
  }
  
  override func test_loadFeedActions_runsAutomaticallyOnlyOnFirstAppearance() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view appears")

    sut.simulateAppearance()
    XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view appears")

    sut.simulateAppearance()
    XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no loading request the second time view appears")
  }

  
  override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.isShowingLoadingUI, true, "Expected show loading once view appears")
    loader.completeFeedLoading(at: 0)
    XCTAssertEqual(sut.isShowingLoadingUI, false, "Expected no loading once loader is completed")
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(sut.isShowingLoadingUI, true, "Expected show loading once user initiates a reload")
    loader.completeFeedLoading(at: 1)
    XCTAssertEqual(sut.isShowingLoadingUI, false, "Expected no loading once user initiated loading is completed")
    
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(sut.isShowingLoadingUI, true, "Expected show loading once user initiates a reload")
    loader.completeFeedloadingWithError(at: 1)
    XCTAssertFalse(sut.isShowingLoadingUI, "Expected no loading once user initiated loading completes with error")
  }
  
  override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    
    let exp = expectation(description: "Wait for background queue")
    DispatchQueue.global().async {
      loader.completeFeedLoading(at: 0)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.errorMessage, nil)
    
    loader.completeFeedloadingWithError(at: 0)
    XCTAssertEqual(sut.errorMessage, loadError)
    
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(sut.errorMessage, nil)
  }
  
  override func test_tapOnErrorView_hideErrorMessage() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.errorMessage, nil)
    
    loader.completeFeedloadingWithError(at: 0)
    XCTAssertEqual(sut.errorMessage, loadError)
    
    sut.simulateErrorViewTap()
    XCTAssertEqual(sut.errorMessage, nil)
  }
  
  //MARK: - Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(loader, file: file, line: line)
    return (sut, loader)
  }
  
  private class LoaderSpy: FeedLoader {
    var loadCommentsCallCount: Int {
      requests.count
    }
    
    private(set) var cancelledImageURLs: [URL] = []
    
    private var requests: [(FeedLoader.Result) -> Void] = []
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      requests.append(completion)
    }
    
    func completeFeedLoading(with images: [FeedImage] = [], at index: Int = 0) {
      requests[index](.success(images))
    }
    
    func completeFeedloadingWithError(at index: Int) {
      requests[index](.failure(anyNSError()))
    }
  }
}

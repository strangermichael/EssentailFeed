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
import EssentialFeedPresentation

class CommentsUIIntegrationTests: XCTestCase {
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
  
  func test_loadCommentActions_runsAutomaticallyOnlyOnFirstAppearance() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view appears")

    sut.simulateAppearance()
    XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view appears")

    sut.simulateAppearance()
    XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no loading request the second time view appears")
  }

  
  func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.isShowingLoadingUI, true, "Expected show loading once view appears")
    loader.completeCommentsLoading(at: 0)
    XCTAssertEqual(sut.isShowingLoadingUI, false, "Expected no loading once loader is completed")
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(sut.isShowingLoadingUI, true, "Expected show loading once user initiates a reload")
    loader.completeCommentsLoading(at: 1)
    XCTAssertEqual(sut.isShowingLoadingUI, false, "Expected no loading once user initiated loading is completed")
    
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(sut.isShowingLoadingUI, true, "Expected show loading once user initiates a reload")
    loader.completeCommentsLoadingWithError(at: 1)
    XCTAssertFalse(sut.isShowingLoadingUI, "Expected no loading once user initiated loading completes with error")
  }
  
  func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
    let comment0 = makeComment(message: "a description", username: "a username")
    let comment1 = makeComment(message: "another description", username: "another username")
    
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    assertThat(sut, isRendering: [ImageComment]())
    
    loader.completeCommentsLoading(with: [comment0], at: 0)
    assertThat(sut, isRendering: [comment0])
    
    sut.simulateUserInitiatedReload()
    loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
    assertThat(sut, isRendering: [comment0, comment1])
  }
  
  func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
    let comment = makeComment()
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeCommentsLoading(with: [comment], at: 0)
    assertThat(sut, isRendering: [comment])
    
    sut.simulateUserInitiatedReload()
    loader.completeCommentsLoading(with: [], at: 1)
    assertThat(sut, isRendering: [ImageComment]())
  }
  
  func test_loadCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
    let comment = makeComment()
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    loader.completeCommentsLoading(with: [comment], at: 0)
    assertThat(sut, isRendering: [comment])
    
    sut.simulateUserInitiatedReload()
    loader.completeCommentsLoadingWithError(at: 1)
    assertThat(sut, isRendering: [comment])
  }
  
  func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    
    let exp = expectation(description: "Wait for background queue")
    DispatchQueue.global().async {
      loader.completeCommentsLoading(at: 0)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.errorMessage, nil)
    
    loader.completeCommentsLoadingWithError(at: 0)
    XCTAssertEqual(sut.errorMessage, loadError)
    
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(sut.errorMessage, nil)
  }
  
  func test_tapOnErrorView_willhideErrorMessage() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.errorMessage, nil)
    
    loader.completeCommentsLoadingWithError(at: 0)
    XCTAssertEqual(sut.errorMessage, loadError)
    
    sut.simulateErrorViewTap()
    XCTAssertEqual(sut.errorMessage, nil)
  }
  
  //MARK: - Helpers
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(loader, file: file, line: line)
    return (sut, loader)
  }
  
  private class LoaderSpy: ImageCommentLoader {
    var loadCommentsCallCount: Int {
      requests.count
    }
    
    private(set) var cancelledImageURLs: [URL] = []
    
    private var requests: [(ImageCommentLoader.Result) -> Void] = []
    
    func load(completion: @escaping (ImageCommentLoader.Result) -> Void) {
      requests.append(completion)
    }
    
    func completeCommentsLoading(with images: [ImageComment] = [], at index: Int = 0) {
      requests[index](.success(images))
    }
    
    func completeCommentsLoadingWithError(at index: Int) {
      requests[index](.failure(anyNSError()))
    }
  }
  
  private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
    ImageComment(id: UUID(), message: message, createdAt: .now, userName: username)
  }
  
  private func anyImageData() -> Data {
    UIImage.make(withColor: .red).pngData()!
  }
  
  private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
    guard sut.numberOfRenderedComments() == comments.count else {
      return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
    }
    let viewModel = ImageCommentsPresenter.map(comments)
    viewModel.comments.enumerated().forEach { index, comment in
      XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
      XCTAssertEqual(sut.commentDate(at: index), comment.date, "message at \(index)", file: file, line: line)
      XCTAssertEqual(sut.commentUserName(at: index), comment.username, "message at \(index)", file: file, line: line)
    }
  }
}

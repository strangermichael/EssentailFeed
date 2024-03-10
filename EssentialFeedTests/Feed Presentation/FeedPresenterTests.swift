//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/2/25.
//

import XCTest

protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

struct FeedErrorViewModel {
  let message: String?
  
  static var noError: FeedErrorViewModel {
    .init(message: nil)
  }
  
  static func error(message: String) -> FeedErrorViewModel {
    .init(message: message)
  }
}

class FeedPresenter {
  private let errorView: FeedErrorView
  
  init(view: FeedErrorView) {
    self.errorView = view
  }
  
  func didStartLoadingFeed() {
    errorView.display(.noError)
  }
}

class FeedPresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessagesToView() {
    let (_, view) = makeSUT()
    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }
  
  func test_didStartLoadingFeed_displayNoErrorMessage() {
    let (sut, view) = makeSUT()
    sut.didStartLoadingFeed()
    XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
  }
  
  //MARK: - Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(view: view)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }
  
  
  private class ViewSpy: FeedErrorView {
    enum Message: Equatable {
      case display(errorMessage: String?)
    }
    
    private(set) var messages: [Message] = []
    
    func display(_ viewModel: FeedErrorViewModel) {
      messages.append(.display(errorMessage: viewModel.message))
    }
    
  }
  
}

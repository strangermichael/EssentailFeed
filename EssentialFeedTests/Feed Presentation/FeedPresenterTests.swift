//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/2/25.
//

import XCTest

class FeedPresenter {
  init(view: Any) {
    
  }
  
  func didStartLoadingFeed() {
    
  }
}

class FeedPresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessagesToView() {
    let (_, view) = makeSUT()
    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }
  
  func test_didStartLoadingFeed_displayNoErrorMessage() {
//    let (sut, view) = makeSUT()
//    sut.didStartLoadingFeed()
//    XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
  }
  
  //MARK: - Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(view: view)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }
  
  
  private class ViewSpy {
    enum Message: Equatable {
      case display(errorMessage: String?)
    }
    
    let messages: [Message] = []
    
  }
  
}

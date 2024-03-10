//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/3/10.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
  associatedtype Image
  
  func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
  private let view: View
  
  init(view: View) {
    self.view = view
  }
  
  func didStartLoadingImageData(for model: FeedImage) {
    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: nil,
      isLoading: true,
      shouldRetry: false))
  }
  
  func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: nil,
      isLoading: false,
      shouldRetry: true))
  }
}

struct FeedImageViewModel<Image> {
  let description: String?
  let location: String?
  let image: Image?
  let isLoading: Bool
  let shouldRetry: Bool
  
  var hasLocation: Bool {
    return location != nil
  }
}

final class FeedImagePresenterTests: XCTestCase {
  
  func test_init_doesNotSendAnyMessages() {
    let (_, view) = makeSUT()
    XCTAssertEqual(view.messages, [])
  }
  
  
  func test_didStartLoadingImageData_displayNoImageAndShowLoadingAndShowRetry() {
    let (sut, view) = makeSUT()
    let image = uniqueImage()
    sut.didStartLoadingImageData(for: image)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(view)
    XCTAssertEqual(view.messages, [.display(image: nil),
                                   .display(location: image.location),
                                   .display(description: image.description),
                                   .display(isLoading: true),
                                   .display(shouldRetry: false)
                                  ])
  }
  
  func test_didFinishLoadingImageDataWithError_displayNoImageAndNoLoadingAndNoRetry() {
    let (sut, view) = makeSUT()
    let image = uniqueImage()
    sut.didFinishLoadingImageData(with: anyNSError(), for: image)
    XCTAssertEqual(view.messages, [.display(image: nil),
                                   .display(location: image.location),
                                   .display(description: image.description),
                                   .display(isLoading: false),
                                   .display(shouldRetry: true)
                                  ])
  }
  
  //MARK: - helper
  private func makeSUT() -> (FeedImagePresenter<ViewSpy, AnyImage>, ViewSpy) {
    let view = ViewSpy()
    let presenter = FeedImagePresenter<ViewSpy, AnyImage>(view: view)
    return (presenter, view)
  }
  
}

struct AnyImage: Hashable { }


class ViewSpy: FeedImageView {
  enum Message: Hashable {
    case display(image: Image?)
    case display(isLoading: Bool)
    case display(shouldRetry: Bool)
    case display(description: String?)
    case display(location: String?)
  }
  
  typealias Image = AnyImage
  
  private(set) var messages: Set<Message> = []
  
  func display(_ model: FeedImageViewModel<Image>) {
    messages.insert(.display(image: model.image))
    messages.insert(.display(isLoading: model.isLoading))
    messages.insert(.display(shouldRetry: model.shouldRetry))
    messages.insert(.display(description: model.description))
    messages.insert(.display(location: model.location))
  }
}

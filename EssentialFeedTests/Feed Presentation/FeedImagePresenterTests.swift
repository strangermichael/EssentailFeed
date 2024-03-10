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
  private let imageTransformer: (Data) -> Image?
  
  init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
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
  
  private struct InvalidImageDataError: Error {}
  
  func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
    guard let image = imageTransformer(data) else {
      return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
    }
    
    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: image,
      isLoading: false,
      shouldRetry: false))
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
    XCTAssertEqual(view.messages, [.display(image: nil),
                                   .display(location: image.location),
                                   .display(description: image.description),
                                   .display(isLoading: true),
                                   .display(shouldRetry: false)
                                  ])
  }
  
  func test_didFinishLoadingImageDataWithError_displayNoImageAndNoLoadingAndShowRetry() {
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
  
  func test_didFinishLoadingImageDataSuccess_displayImageAndHideRetryAndIsLoading() {
    let (sut, view) = makeSUT()
    let image = uniqueImage()
    let data = Data()
    let expecedImage = AnyImage()
    sut.didFinishLoadingImageData(with: data, for: image)
    XCTAssertEqual(view.messages, [.display(image: expecedImage),
                                   .display(location: image.location),
                                   .display(description: image.description),
                                   .display(isLoading: false),
                                   .display(shouldRetry: false)
                                  ])
  }
  
  func test_didFinishLoadingImageDataTransformImageFailed_displayNoImageAndShowRetryAndNoLoading() {
    let imageTransformer: (Data) -> AnyImage? = { _ in return nil }
    let (sut, view) = makeSUT(imageTransformer: imageTransformer)
    let image = uniqueImage()
    let data = Data()
    sut.didFinishLoadingImageData(with: data, for: image)
    XCTAssertEqual(view.messages, [.display(image: nil),
                                   .display(location: image.location),
                                   .display(description: image.description),
                                   .display(isLoading: false),
                                   .display(shouldRetry: true)
                                  ])
  }
  
  //MARK: - helper
  private func makeSUT(imageTransformer: ((Data) -> AnyImage?)? = nil) -> (FeedImagePresenter<ViewSpy, AnyImage>, ViewSpy) {
    let defaultTransformer: (Data) -> AnyImage? = { _ in return AnyImage() }
    let view = ViewSpy()
    let presenter = FeedImagePresenter<ViewSpy, AnyImage>(view: view, imageTransformer: imageTransformer ?? defaultTransformer)
    trackForMemoryLeaks(view)
    trackForMemoryLeaks(presenter)
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

//
//  FeedUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/1/30.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class FeedUIIntegrationTests: XCTestCase {
  
  func test_feedView_hasTitle() {
    let (sut, _) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.title, feedTitle)
  }
  
  func test_loadFeedActions_requestFeedFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view appears")
    sut.simulateAppearance()
    XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected no loading requests once view appears")
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading requests once usee initiates a load")
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading requests once usee initiates another load")
  }
  
  func test_loadFeedActions_runsAutomaticallyOnlyOnFirstAppearance() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view appears")

    sut.simulateAppearance()
    XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view appears")

    sut.simulateAppearance()
    XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected no loading request the second time view appears")
  }

  
  func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
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
  
  func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
    let image0 = makeImage(description: "a description", location: "a location")
    let image1 = makeImage(description: nil, location: "another location")
    let image2 = makeImage(description: "another description", location: nil)
    let image3 = makeImage(description: nil, location: "nil")
    
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    assertThat(sut, isRendering: [])
    
    loader.completeFeedLoading(with: [image0, image1], at: 0)
    assertThat(sut, isRendering: [image0, image1])
    
    sut.simulateLoadMoreFeedAction()
    loader.completLoadMore(images: [image0, image1, image2, image3], lastPage: false, at: 0)
    assertThat(sut, isRendering: [image0, image1, image2, image3]) //loadmore回来的closure时全量数据
    
    sut.simulateUserInitiatedReload()
    loader.completeFeedLoading(with: [image0, image1, image2], at: 1)
    assertThat(sut, isRendering: [image0, image1, image2])
  }
  
  func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
    let image0 = makeImage()
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRendering: [image0])
    
    sut.simulateUserInitiatedReload()
    loader.completeFeedloadingWithError(at: 1)
    assertThat(sut, isRendering: [image0])
    
    sut.simulateLoadMoreFeedAction()
    loader.completLoadMoreWithError(at: 0)
    assertThat(sut, isRendering: [image0])
  }
  
  func test_feedImageView_loadsImageURLWhenVisible() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0, image1], at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image url requests until views become visible")
    
    sut.simulateFeedImageViewVisible(at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image url requests once first view becomes visible")
    
    sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image url requests once second view becomes visible")
  }
  
  func test_feedImageView_cancelsImageLoadingWhenNotVisible() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0, image1], at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image url requests until image is not visible")
    
    sut.simulateFeedImageViewNotVisible(at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image url request once first view is not visible")
    
    sut.simulateFeedImageViewNotVisible(at: 1)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image url requests once second view is not visible")
  }
  
  func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])
    
    let view0 = sut.simulateFeedImageViewVisible(at: 0)
    let view1 = sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
    XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
    loader.completeImageLoading(at: 0)
    XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
    loader.completeImageLoadingWithError(at: 1)
    XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
  }
  
  func test_feedImageView_rendersImageLoadedFromURL() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])
    let view0 = sut.simulateFeedImageViewVisible(at: 0)
    let view1 = sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
    XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
    
    let imageData0 = anyImageData() //not load from disk
    loader.completeImageLoading(with: imageData0, at: 0)
    XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once loading completes successfully")
    
    let imageData1 = UIImage.make(withColor: .blue).pngData()!
    loader.completeImageLoading(with: imageData1, at: 1)
    XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once loading completes successfully")
  }
  
  func test_loadMoreActions_requestMoreFromLoader() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])
    XCTAssertEqual(loader.loadMoreCallCount, 0, "Expected no load more requests until load more action")
    sut.simulateLoadMoreFeedAction()
    XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected load more requests once load more")
    sut.simulateLoadMoreFeedAction()
    XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected no request while loading more")
    
    loader.completLoadMore(images: [makeImage()], lastPage: false, at: 0)
    sut.simulateLoadMoreFeedAction()
    XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected request after finishing loading more")
    
    loader.completLoadMoreWithError(at: 1)
    sut.simulateLoadMoreFeedAction()
    XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected request after finishing loading more")
    
    loader.completLoadMore(images: [makeImage()], lastPage: true, at: 2)
    sut.simulateLoadMoreFeedAction()
    XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected no more request after got the last page data")
  }
  
  func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])
    let view0 = sut.simulateFeedImageViewVisible(at: 0)
    let view1 = sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(view0?.isShowingRetryAction, false)
    XCTAssertEqual(view1?.isShowingRetryAction, false)
    
    let imageData0 = anyImageData() //not load from disk
    loader.completeImageLoading(with: imageData0, at: 0)
    XCTAssertEqual(view0?.isShowingRetryAction, false)
    
    loader.completeImageLoadingWithError(at: 1)
    XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once load failed")
  }
  
  func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])
    let view0 = sut.simulateFeedImageViewVisible(at: 0)
    XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action while loading image")
    let invalidData = Data("invalid image data".utf8)
    loader.completeImageLoading(with: invalidData, at: 0)
    XCTAssertEqual(view0?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
  }
  
  func test_feedImageViewRetryAction_retriesImageLoad() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0, image1])
    let view0 = sut.simulateFeedImageViewVisible(at: 0)
    let view1 = sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image url requests for two visible view")
    view0?.simulateRetryAction()
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected three image url requests after frist view retry action")
    view1?.simulateRetryAction()
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected four image url requests after second view retry action")
  }
  
  func test_feedImageView_preloadsImageURLWhenNearVisible() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0, image1], at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image url requests until views is near visible")
    
    sut.simulateFeedImageViewNearVisible(at: 0)
     XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image url requests once first view is near visible")
    
    sut.simulateFeedImageViewNearVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image url requests once second view is near visible")
  }
  
  func test_feedImageView_cancelImageUrlLoadingWhenNotNearVisible() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0, image1], at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cacncelled image url requests until views is not near visible")
    
    sut.simulateFeedImageViewNotNearVisible(at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cacncelled image url requests once first view is not near visible")
    
    sut.simulateFeedImageViewNotNearVisible(at: 1)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cacncelled image url requests once second view is not near visible")
  }
  
  func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [makeImage()])
    let view = sut.simulateFeedImageViewNotVisible(at: 0)
    loader.completeImageLoading(with: anyImageData())
    XCTAssertEqual(view?.renderedImage, nil, "Expected no rendered image when an image load finishes after the view is not visible any more")
  }
  
  func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    
    let exp = expectation(description: "Wait for background queue")
    DispatchQueue.global().async {
      loader.completeFeedLoading(at: 0)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_loadMoreCompletion_dispatchesFromBackgroundToMainThread() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading(at: 0)
    sut.simulateLoadMoreFeedAction()
    
    let exp = expectation(description: "Wait for background queue")
    DispatchQueue.global().async {
      loader.completLoadMore(images: [self.makeImage()], lastPage: false, at: 0)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_loadImageDataComletion_dispatchesFromBackgroundToMainThread() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [makeImage()], at: 0)
    _ = sut.simulateFeedImageViewVisible(at: 0)
    let exp = expectation(description: "Wait for background queue")
    DispatchQueue.global().async {
      loader.completeImageLoading(with: self.anyImageData(), at: 0)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.errorMessage, nil)
    
    loader.completeFeedloadingWithError(at: 0)
    XCTAssertEqual(sut.errorMessage, loadError)
    
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(sut.errorMessage, nil)
  }
  
  func test_tapOnErrorView_hideErrorMessage() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.errorMessage, nil)
    
    loader.completeFeedloadingWithError(at: 0)
    XCTAssertEqual(sut.errorMessage, loadError)
    
    sut.simulateErrorViewTap()
    XCTAssertEqual(sut.errorMessage, nil)
  }

  func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
    let image0 = makeImage()
    let image1 = makeImage()
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRendering: [image0])
    
    sut.simulateLoadMoreFeedAction()
    loader.completLoadMore(images: [image0, image1], lastPage: false, at: 0)
    assertThat(sut, isRendering: [image0, image1]) //loadmore回来的closure时全量数据
    
    sut.simulateUserInitiatedReload()
    loader.completeFeedLoading(with: [], at: 1)
    assertThat(sut, isRendering: [])
  }
  
  func test_imageSelection_notifiesHandler() {
    let image0 = makeImage()
    let image1 = makeImage()
    var selectedImages: [FeedImage] = []
    let (sut, loader) = makeSUT(selection: { selectedImages.append($0) } )
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0, image1], at: 0)
    sut.simulaTapOnFeedImage(at: 0)
    XCTAssertEqual(selectedImages, [image0])
    
    sut.simulaTapOnFeedImage(at: 1)
    XCTAssertEqual(selectedImages, [image0, image1])
  }
  
  func test_loadingMore_isVisibleWhileLoadingMore() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    XCTAssertEqual(sut.isShowingLoadingMore, false, "Expected no loading more once view appears")
    loader.completeFeedLoading(at: 0)
    XCTAssertEqual(sut.isShowingLoadingMore, false, "Expected no loading once loader is completed")
    sut.simulateLoadMoreFeedAction()
    XCTAssertEqual(sut.isShowingLoadingMore, true, "Expected show loading once user initiates load more")
    loader.completLoadMore(images: [makeImage()], lastPage: false, at: 0)
    XCTAssertEqual(sut.isShowingLoadingMore, false, "Expected no loading more once user finish load more")
    sut.simulateLoadMoreFeedAction()
    XCTAssertEqual(sut.isShowingLoadingMore, true, "Expected show loading once user initiates load more")
    loader.completLoadMoreWithError(at: 1)
    XCTAssertEqual(sut.isShowingLoadingMore, false, "Expected no loading more once user finish load more")
  }
  
  func test_loadMoreCompletion_rendersErrorMessageOnError() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading()
    
    sut.simulateLoadMoreFeedAction()
    XCTAssertEqual(sut.loadMoreErrorMessage, nil)
    
    loader.completLoadMoreWithError(at: 0)
    XCTAssertEqual(sut.loadMoreErrorMessage, loadError)
  }
  
  func test_tapLoadMoreErrorView_loadsMore() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    loader.completeFeedLoading()
    
    sut.simulateLoadMoreFeedAction()
    XCTAssertEqual(loader.loadMoreCallCount, 1)
    
    sut.simulateTapOnLoadMoreError()
    XCTAssertEqual(loader.loadMoreCallCount, 1)
    
    
    loader.completLoadMoreWithError(at: 0)
    sut.simulateTapOnLoadMoreError()
    XCTAssertEqual(loader.loadMoreCallCount, 2)
  }
  
  //MARK: - Helpers
  private func makeSUT(selection: @escaping (FeedImage) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader, selection: selection)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(loader, file: file, line: line)
    return (sut, loader)
  }
  
  private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
    FeedImage(id: UUID(), description: description, location: location, imageURL: url)
  }
  
  private func anyImageData() -> Data {
    UIImage.make(withColor: .red).pngData()!
  }
}

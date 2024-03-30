//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/3/29.
//

import XCTest
import EssentialFeediOS
import EssentialFeed
import UIKit

final class FeedSnapshotTests: XCTestCase {
  
  func test_emptyFeed() {
    let sut = makeSUT()
    sut.display(cellControllers: emptyFeed())
    record(snapshot: sut.snapshot(), name: "EMPTY_FEED")
  }
  
  func test_feedWithContent() {
    let sut = makeSUT()
    sut.display(feedWithContent())
    record(snapshot: sut.snapshot(), name: "FEED_WITH_CONTENT")
  }
  
  func test_feedWithErrorMessage() {
    let sut = makeSUT()
    sut.display(.error(message: "This is a \n multiple line \n message"))
    record(snapshot: sut.snapshot(), name: "FEED_WITH_ERROR_MESSAGE")
  }
  
  func test_feedWithFailedImageLoading() {
    let sut = makeSUT()
    sut.display(feedWithFailedImageLoading())
    record(snapshot: sut.snapshot(), name: "FEED_WITH_FAILED_IMAGE_LOADING")
  }
  
  private func makeSUT() -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let controller = storyboard.instantiateInitialViewController() as! FeedViewController
    controller.loadViewIfNeeded()
    return controller
  }
  
  private func emptyFeed() -> [FeedImageCellController] {
    []
  }
  
  private func feedWithContent() -> [ImageStub] {
    [
      ImageStub(description: "Test description", location: "East Side Gallery", image: UIImage.make(withColor: .red)),
      ImageStub(description: "Garth Pier description", location: "Garth Pier", image: UIImage.make(withColor: .purple))
    ]
  }
  
  private func feedWithFailedImageLoading() -> [ImageStub] {
    [
      ImageStub(description: nil, location: "East Side Gallery", image: nil),
      ImageStub(description: nil, location: "Garth Pier", image: nil)
    ]
  }
  
  //#file means current file
  private func record(snapshot: UIImage, name: String, file: StaticString = #file, line: UInt = #line) {
    guard let snapshotData = snapshot.pngData() else {
      XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
      return
    }
    
    let snapshotURL = URL(fileURLWithPath: String(describing: file)).deletingLastPathComponent().appendingPathComponent("snapshots").appendingPathComponent("\(name).png")
    do {
      try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      try snapshotData.write(to: snapshotURL)
    } catch {
      XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
    }
  }
}

extension UIViewController {
  func snapshot() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
    return renderer.image { action in
      view.layer.render(in: action.cgContext)
    }
  }
}

private extension FeedViewController {
  func display(_ stubs: [ImageStub]) {
    let cells: [FeedImageCellController] = stubs.map { stub in
      let cellController = FeedImageCellController(delegate: stub)
      stub.controller = cellController
      return cellController
    }
    display(cellControllers: cells)
  }
}

private class ImageStub: FeedImageCellControllerDelegate {
  weak var controller: FeedImageCellController?
  let viewModel: FeedImageViewModel<UIImage>
  
  init(description: String?, location: String?, image: UIImage?) {
    viewModel = FeedImageViewModel(description: description,
                                   location: location,
                                   image: image,
                                   isLoading: false,
                                   shouldRetry: image == nil
    )
  }
  
  func didRequestImage() {
    controller?.display(viewModel)
  }
  
  func didCancelImageRequest() {
    
  }
}

extension UIImage {
  static func make(withColor color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
      color.setFill()
      rendererContext.fill(rect)
    }
  }
}

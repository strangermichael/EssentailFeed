//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/3/29.
//

import UIKit
import XCTest
import EssentialFeediOS
import EssentialFeed
import EssentialFeedPresentation

final class FeedSnapshotTests: XCTestCase {
  func test_feedWithContent() {
    let sut = makeSUT()
    sut.display(feedWithContent())
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
  }
  
  func test_feedWithFailedImageLoading() {
    let sut = makeSUT()
    sut.display(feedWithFailedImageLoading())
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
  }
  
  //MARK: - Helper
  private func makeSUT() -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let controller = storyboard.instantiateInitialViewController() as! ListViewController
    controller.loadViewIfNeeded()
    controller.tableView.showsVerticalScrollIndicator = false
    controller.tableView.showsHorizontalScrollIndicator = false
    return controller
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
}

extension UIViewController {
  func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
    return SnapshotWindow(configuration: configuration, root: self).snapshot()
  }
}

private extension ListViewController {
  func display(_ stubs: [ImageStub]) {
    let cells: [CellController] = stubs.map { stub in
      let cellController = FeedImageCellController(delegate: stub)
      stub.controller = cellController
      return CellController(cellController)
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

struct SnapshotConfiguration {
  let size: CGSize
  let safeAreaInsets: UIEdgeInsets
  let layoutMargins: UIEdgeInsets
  let traitCollection: UITraitCollection
  
  static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
    return SnapshotConfiguration(
      size: CGSize(width: 375, height: 667),
      safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
      layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
      traitCollection: UITraitCollection(traitsFrom: [
        .init(forceTouchCapability: .available),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .medium),
        .init(userInterfaceIdiom: .phone),
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .regular),
        .init(displayScale: 2),
        .init(displayGamut: .P3),
        .init(userInterfaceStyle: style)
      ]))
  }
}

private final class SnapshotWindow: UIWindow {
  private var configuration: SnapshotConfiguration = .iPhone8(style: .light)
  
  convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
    self.init(frame: CGRect(origin: .zero, size: configuration.size))
    self.configuration = configuration
    self.layoutMargins = configuration.layoutMargins
    self.rootViewController = root
    self.isHidden = false
    root.view.layoutMargins = configuration.layoutMargins
  }
  
  override var safeAreaInsets: UIEdgeInsets {
    return configuration.safeAreaInsets
  }
  
  override var traitCollection: UITraitCollection {
    return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
  }

  func snapshot() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
    return renderer.image { action in
      layer.render(in: action.cgContext)
    }
  }
}

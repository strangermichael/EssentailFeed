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
  
  func test_emptyFeed() {
    let sut = makeSUT()
    sut.display(cellControllers: emptyFeed())
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_dark")
  }
  
  func test_feedWithContent() {
    let sut = makeSUT()
    sut.display(feedWithContent())
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
  }
  
  func test_feedWithErrorMessage() {
    let sut = makeSUT()
    sut.display(.error(message: "This is a \n multiple line \n message"))
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_dark")
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
  
  private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
    let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
    let snapshotURL = makeSnapshotURL(named: name, file: file)
    guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
      XCTFail("Failed to load stored snapshot at url \(snapshotURL). Use the record method to store a snapshot before asserting", file: file, line: line)
      return
    }
    if snapshotData != storedSnapshotData {
      let temSnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(snapshotURL.lastPathComponent)
      try? snapshotData?.write(to: temSnapshotURL)
      XCTFail("New snapshot does not match stored snapshot. New snapshot url: \(temSnapshotURL), stored snapshot url: \(snapshotURL)", file: file, line: line)
    }
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
  private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
    let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
    let snapshotURL = makeSnapshotURL(named: name, file: file)
    do {
      try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      try snapshotData?.write(to: snapshotURL)
    } catch {
      XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
    }
  }
  
  private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
    URL(fileURLWithPath: String(describing: file)).deletingLastPathComponent().appendingPathComponent("snapshots").appendingPathComponent("\(name).png")
  }
  
  private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
    guard let snapshotData = snapshot.pngData() else {
      XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
      return nil
    }
    return snapshotData
  }
}

extension UIViewController {
  func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
    return SnapshotWindow(configuration: configuration, root: self).snapshot()
  }
}

private extension ListViewController {
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

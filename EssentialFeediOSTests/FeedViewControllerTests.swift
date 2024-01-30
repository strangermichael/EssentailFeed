//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/1/30.
//

import XCTest
import UIKit

final class FeedViewController: UIViewController {
  private var loader: FeedViewControllerTests.LoaderSpy?
  
  init(loader: FeedViewControllerTests.LoaderSpy) {
    super.init(nibName: nil, bundle: nil)
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loader?.load()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class FeedViewControllerTests: XCTestCase {
  
  func test_init_doesNotLoadFeed() {
    let loader = LoaderSpy()
    _ = FeedViewController(loader: loader)
    XCTAssertEqual(loader.loadCallCount, 0)
  }
  
  func test_viewDidLoad_loadsFeed() {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadCallCount, 1)
  }
  
  //MARK: - Helpers
  class LoaderSpy {
    private(set) var loadCallCount: Int = 0
    
    func load() {
      loadCallCount += 1
    }
  }
  
}

//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/1/30.
//

import XCTest
import UIKit
import EssentailFeed

final class FeedViewController: UIViewController {
  private var loader: FeedLoader?
  
  init(loader: FeedLoader) {
    super.init(nibName: nil, bundle: nil)
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loader?.load(completion: { _ in
      
    })
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class FeedViewControllerTests: XCTestCase {
  
  func test_init_doesNotLoadFeed() {
    let (_, loader) = makeSUT()
    XCTAssertEqual(loader.loadCallCount, 0)
  }
  
  func test_viewDidLoad_loadsFeed() {
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadCallCount, 1)
  }
  
  //MARK: - Helpers
  class LoaderSpy: FeedLoader {
    private(set) var loadCallCount: Int = 0
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      loadCallCount += 1
    }
  }
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }
  
}

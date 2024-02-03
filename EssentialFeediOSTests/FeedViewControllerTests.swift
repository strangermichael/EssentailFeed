//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/1/30.
//

import XCTest
import UIKit
import EssentailFeed

final class FeedViewController: UITableViewController {
  private var loader: FeedLoader?
  
  init(loader: FeedLoader) {
    super.init(nibName: nil, bundle: nil)
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    load()
  }
  
  @objc private func load() {
    refreshControl?.beginRefreshing()
    loader?.load(completion: {[weak self] _ in
      self?.refreshControl?.endRefreshing()
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
  
  func test_pullToRefresh_loadsFeed() {
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()
    sut.refreshControl?.simulatePullToRefresh()
    XCTAssertEqual(loader.loadCallCount, 2)
    sut.refreshControl?.simulatePullToRefresh()
    XCTAssertEqual(loader.loadCallCount, 3)
  }
  
  func test_viewDidLoad_showsLoadingIndicator() {
    let (sut, _) = makeSUT()
    sut.loadViewIfNeeded()
    XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
  }
  
  func test_viewDidLoad_hideLoadingIndicatorOnLoaderCompletion() {
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()
    loader.completFeedLoading()
    XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
  }
  
  func test_pullToRefresh_showsLoadingIndicator() {
    let (sut, _) = makeSUT()
    sut.refreshControl?.simulatePullToRefresh()
    XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
  }
  
  func test_pullToRefresh_hideLoadingIndicatorOnLoaderCompletion() {
    let (sut, loader) = makeSUT()
    sut.refreshControl?.simulatePullToRefresh()
    loader.completFeedLoading()
    XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
  }
  
  //MARK: - Helpers
  class LoaderSpy: FeedLoader {
    var loadCallCount: Int {
      completions.count
    }
    private var completions: [(FeedLoader.Result) -> Void] = []
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completions.append(completion)
    }
    
    func completFeedLoading() {
      completions[0](.success([]))
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

private extension UIRefreshControl {
  //no need to actually trigger the UI, just need to trigger the action UI binds
  func simulatePullToRefresh() {
    allTargets.forEach({ target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ actionString in
        (target as NSObject).perform(Selector(actionString))
      })
    })
  }
}

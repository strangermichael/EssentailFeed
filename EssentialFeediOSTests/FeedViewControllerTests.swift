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
  
  func test_loadFeedActions_requestFeedFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadCallCount, 0)
    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadCallCount, 1)
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 2)
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 3)
  }
  
  func test_viewDidLoad_showsLoadingIndicator() {
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()
    XCTAssertEqual(sut.isShowingLoadingUI, true)
    loader.completFeedLoading(at: 0)
    XCTAssertEqual(sut.isShowingLoadingUI, false)
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(sut.isShowingLoadingUI, true)
    loader.completFeedLoading(at: 1)
    XCTAssertEqual(sut.isShowingLoadingUI, false)
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
    
    func completFeedLoading(at index: Int) {
      completions[index](.success([]))
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

private extension FeedViewController {
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }
  
  var isShowingLoadingUI: Bool {
    refreshControl?.isRefreshing == true
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

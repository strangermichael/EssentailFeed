//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/2/24.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
  func simulateAppearance() {
    if !isViewLoaded {
      loadViewIfNeeded()
      prepareForFirstAppearance()
    }
    beginAppearanceTransition(true, animated: false)
    endAppearanceTransition()
  }
  
  private func prepareForFirstAppearance() {
    setSmallFrameToPreventRenderingCells()
    replaceRefreshControlWithFakeForiOS17PlusSupport()
  }
  
  private func setSmallFrameToPreventRenderingCells() {
    tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
  }
  
  private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
    let fakeRefreshControl = FakeUIRefreshControl()
    
    refreshControl?.allTargets.forEach { target in
      refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
        fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
      }
    }
    
    refreshControl = fakeRefreshControl
  }
  
  private class FakeUIRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
      _isRefreshing = true
    }
    
    override func endRefreshing() {
      _isRefreshing = false
    }
  }
  
  func simulateUserInitiatedReload() {
    refreshControl?.simulatePullToRefresh()
  }
  
  var isShowingLoadingUI: Bool {
    refreshControl?.isRefreshing == true
  }
  
  var isShowingLoadingMore: Bool {
    loadMoreCell()?.isLoading == true
  }
  
  private func loadMoreCell() -> LoadMoreCell? {
    cell(row: 0, section: feedLoadMoreSection) as? LoadMoreCell
  }
  
  var errorMessage: String? {
    errorView.message
  }
  
  var loadMoreErrorMessage: String? {
    loadMoreCell()?.message
  }
  
  func simulateErrorViewTap() {
    errorView.simulateTap()
  }
}

extension ListViewController {
  @discardableResult
  func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
    feedImageView(at: index) as? FeedImageCell
  }
  
  @discardableResult
  func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
    let view = simulateFeedImageViewVisible(at: row)
    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    return view
  }
  
  func cell(row: Int, section: Int) -> UITableViewCell? {
    let numberOfRenderedFeedImageViews = tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: section)
    guard numberOfRenderedFeedImageViews > row else {
      return nil
    }
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: section)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
  
  func numberOfRenderedFeedImageViews() -> Int {
    //diff datasource 只有第一个snapshot来的时候section才不为0
    tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
  }
  
  private var feedImagesSection: Int {
    0
  }
  
  private var feedLoadMoreSection: Int {
    1
  }
  
  func feedImageView(at row: Int) -> UITableViewCell? {
    guard numberOfRenderedFeedImageViews() > row else {
      return nil
    }
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
  
  func simulateFeedImageViewNearVisible(at row: Int) {
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView(tableView, prefetchRowsAt: [index])
  }
  
  func simulateFeedImageViewNotNearVisible(at row: Int) {
    simulateFeedImageViewNearVisible(at: row)
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
  }
  
  func simulaTapOnFeedImage(at row: Int) {
    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didSelectRowAt: index)
  }
  
  func simulateTapOnLoadMoreError() {
    let delegate = tableView.delegate
    let index = IndexPath(row: 0, section: feedLoadMoreSection)
    delegate?.tableView?(tableView, didSelectRowAt: index)
  }
  
  func simulateLoadMoreFeedAction() {
    guard let view = loadMoreCell() else { return }
    let delegate = tableView.delegate
    let index = IndexPath(row: 0, section: feedLoadMoreSection)
    delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
  }
}


extension ListViewController {
  func numberOfRenderedComments() -> Int {
    //diff datasource 只有第一个snapshot来的时候section才不为0
    tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
  }
  
  private var commentsSection: Int {
    0
  }
  
  func commentMessage(at row: Int) -> String? {
    commentView(at: row)?.messageLabel.text
  }
  
  func commentDate(at row: Int) -> String? {
    commentView(at: row)?.dateLabel.text
  }
  
  func commentUserName(at row: Int) -> String? {
    commentView(at: row)?.userNameLabel.text
  }
  
  private func commentView(at row: Int) -> ImageCommentCell? {
    guard numberOfRenderedFeedImageViews() > row else {
      return nil
    }
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: commentsSection)
    return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
  }
}

//
//  LoadResourcePresenter.swift
//  EssentialFeedPresentation
//
//  Created by Shengjun Xia on 2024/4/5.
//

import Foundation
import EssentialFeed

public class LoadResourcePresenter {
  private let feedView: FeedView
  private let loadingView: FeedLoadingView
  private let errorView: FeedErrorView
  private var feedLoadError: String {
    NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                      tableName: "Feed",
                      bundle: Bundle(for: FeedPresenter.self),
                      comment: "Error message displayed when we can't load the image feed from the server")
  }
  public static var title: String {
    NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed view")
  }
  
  public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
    self.feedView = feedView
    self.loadingView = loadingView
    self.errorView = errorView
  }
  
  public func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
  }
  
  public func didFinishLoadingFeed(with feed: [FeedImage]) {
    feedView.display(viewModel: FeedViewModel(feed: feed))
    loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
  }
  
  public func didFinishLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
  }

}

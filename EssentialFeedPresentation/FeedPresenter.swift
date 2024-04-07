//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/10.
//

import Foundation
import EssentialFeed

public class FeedPresenter {
  private let feedView: FeedView
  private let loadingView: ResourceLoadingView
  private let errorView: ResourceErrorView
  private var feedLoadError: String {
    NSLocalizedString("GENERIC_VIEW_CONNECTION_ERROR",
                      tableName: "Shared",
                      bundle: Bundle(for: Self.self),
                      comment: "Error message displayed when we can't load the image feed from the server")
  }
  public static var title: String {
    NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed view")
  }
  
  public init(feedView: FeedView, loadingView: ResourceLoadingView, errorView: ResourceErrorView) {
    self.feedView = feedView
    self.loadingView = loadingView
    self.errorView = errorView
  }
  
  public func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
  }
  
  public func didFinishLoadingFeed(with feed: [FeedImage]) {
    feedView.display(viewModel: Self.map(feed))
    loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
  }
  
  public func didFinishLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
  }
  
  public static func map(_ feed: [FeedImage]) -> FeedViewModel {
    FeedViewModel(feed: feed)
  }
}

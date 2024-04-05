//
//  LoadResourcePresenter.swift
//  EssentialFeedPresentation
//
//  Created by Shengjun Xia on 2024/4/5.
//

import Foundation
import EssentialFeed

public protocol ResourceView {
  func display(_ viewModel: String)
}

public class LoadResourcePresenter {
  public typealias Mapper = (String) -> String
  private let resourceView: ResourceView
  private let loadingView: FeedLoadingView
  private let errorView: FeedErrorView
  private let mapper: Mapper
  private var feedLoadError: String {
    NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                      tableName: "Feed",
                      bundle: Bundle(for: FeedPresenter.self),
                      comment: "Error message displayed when we can't load the image feed from the server")
  }
  
  public init(resourceView: ResourceView,
              loadingView: FeedLoadingView,
              errorView: FeedErrorView,
              mapper: @escaping Mapper) {
    self.resourceView = resourceView
    self.loadingView = loadingView
    self.errorView = errorView
    self.mapper = mapper
  }
  
  public func didStartLoading() {
    errorView.display(.noError)
    loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
  }
  
  public func didFinishLoadingResource(with resource: String) {
    resourceView.display(mapper(resource))
    loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
  }
  
  public func didFinishLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
  }

}

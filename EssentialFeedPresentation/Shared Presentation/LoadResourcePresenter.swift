//
//  LoadResourcePresenter.swift
//  EssentialFeedPresentation
//
//  Created by Shengjun Xia on 2024/4/5.
//

import Foundation
import EssentialFeed

public protocol ResourceView {
  associatedtype ResourceViewModel
  func display(_ viewModel: ResourceViewModel)
}

public class LoadResourcePresenter<Resource, View: ResourceView> {
  public typealias Mapper = (Resource) -> View.ResourceViewModel
  private let resourceView: View
  private let loadingView: ResourceLoadingView
  private let errorView: ResourceErrorView
  private let mapper: Mapper
  public static var loadError: String {
    NSLocalizedString("GENERIC_VIEW_CONNECTION_ERROR",
                      tableName: "Shared",
                      bundle: Bundle(for: Self.self),
                      comment: "Error message displayed when we can't load the image feed from the server")
  }
  
  public init(resourceView: View,
              loadingView: ResourceLoadingView,
              errorView: ResourceErrorView,
              mapper: @escaping Mapper) {
    self.resourceView = resourceView
    self.loadingView = loadingView
    self.errorView = errorView
    self.mapper = mapper
  }
  
  public func didStartLoading() {
    errorView.display(.noError)
    loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
  }
  
  public func didFinishLoadingResource(with resource: Resource) {
    resourceView.display(mapper(resource))
    loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
  }
  
  public func didFinishLoading(with error: Error) {
    errorView.display(.error(message: Self.loadError))
    loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
  }

}

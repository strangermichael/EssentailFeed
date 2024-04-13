//
//  ResourceLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/24.
//

import EssentialFeed
import EssentialFeediOS
import EssentialFeedPresentation

final class ResourceLoaderPresentationAdapter<Resource, View: ResourceView> {
  typealias Result = Swift.Result<Resource, Error>
  private let loadFuction: (@escaping (Result) -> Void) -> Void
  var presenter: LoadResourcePresenter<Resource, View>?
  
  init(loadFuction: @escaping (@escaping (Result) -> Void) -> Void) {
    self.loadFuction = loadFuction
  }
  
  func loadResource() {
    presenter?.didStartLoading()
    loadFuction { [weak self] result in
      switch result {
      case let .success(resource):
        self?.presenter?.didFinishLoadingResource(with: resource)
      case let .failure(error):
        self?.presenter?.didFinishLoading(with: error)
      }
    }
  }
}

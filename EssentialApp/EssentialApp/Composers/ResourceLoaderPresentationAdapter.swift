//
//  ResourceLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/24.
//

import EssentialFeed
import EssentialFeediOS
import EssentialFeedPresentation

public protocol ResourceLoader {
  associatedtype Resource
  typealias Result = Swift.Result<Resource, Error>
  func load(completion: @escaping (Result) -> Void)
}

final class ResourceLoaderPresentationAdapter<Resource, View: ResourceView, Loader: ResourceLoader> where Loader.Resource == Resource {
  private let loader: Loader
  var presenter: LoadResourcePresenter<Resource, FeedViewAdapter>?
  
  init(loader: Loader) {
    self.loader = loader
  }
  
  func loadResource() {
    presenter?.didStartLoading()
    loader.load { [weak self] result in
      switch result {
      case let .success(resource):
        self?.presenter?.didFinishLoadingResource(with: resource)
      case let .failure(error):
        self?.presenter?.didFinishLoading(with: error)
      }
    }
  }
}

extension ResourceLoaderPresentationAdapter: FeedViewControllerDelegate {
  func didRequestFeedRefresh() {
    loadResource()
  }
}

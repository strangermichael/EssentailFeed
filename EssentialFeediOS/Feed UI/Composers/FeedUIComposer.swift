//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit
import EssentailFeed

public final class FeedUIComposer {
  private init() {}
  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let presenter = FeedPresenter()
    let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
    let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
    let feedController = FeedViewController(refreshController: refreshController)
    presenter.loadingView = WeakRefVirtualProxy(refreshController)
    presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
    return feedController
  }
}

//这个逻辑放在组合层的原因是， [FeedImage]算是其它component的细节，应该放在这里, 万一以后换了其他的组件 搭配UI呢
private final class FeedViewAdapter: FeedView {
  private weak var controller: FeedViewController?
  private let imageLoader: FeedImageDataLoader
  
  init(controller: FeedViewController? = nil, imageLoader: FeedImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }
  
  func display(viewModel: FeedViewModel) {
    controller?.tableModel = viewModel.feed.map { model in
      FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
    }
  }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?
  
  init(_ object: T) {
    self.object = object
  }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
  func display(viewModel: FeedLoadingViewModel) {
    object?.display(viewModel: viewModel)
  }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
  private let feedLoader: FeedLoader
  private let presenter: FeedPresenter
  
  init(feedLoader: FeedLoader, presenter: FeedPresenter) {
    self.feedLoader = feedLoader
    self.presenter = presenter
  }
  
  func didRequestFeedRefresh() {
    presenter.didStartLoadingFeed()
    feedLoader.load { [weak self] result in
      switch result {
      case let .success(feed):
        self?.presenter.didFinishLoadingFeed(with: feed)
      case let .failure(error):
        self?.presenter.didFinishLoadingFeed(with: error)
      }
    }
  }
}

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
    let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
    let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
    let feedController = FeedViewController(refreshController: refreshController)
    let presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader), loadingView: WeakRefVirtualProxy(refreshController))
    presentationAdapter.presenter = presenter
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
      let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
      let view = FeedImageCellController(delegate: adapter)
      adapter.presenter = FeedImagePresenter(
        view: WeakRefVirtualProxy(view),
        imageTransformer: UIImage.init)
      return view
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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
  func display(_ model: FeedImageViewModel<UIImage>) {
    object?.display(model)
  }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
  private let feedLoader: FeedLoader
  var presenter: FeedPresenter?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func didRequestFeedRefresh() {
    presenter?.didStartLoadingFeed()
    feedLoader.load { [weak self] result in
      switch result {
      case let .success(feed):
        self?.presenter?.didFinishLoadingFeed(with: feed)
      case let .failure(error):
        self?.presenter?.didFinishLoadingFeed(with: error)
      }
    }
  }
}

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  private var task: FeedImageDataLoaderTask?
  
  var presenter: FeedImagePresenter<View, Image>?
  
  init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }
  
  func didRequestImage() {
    presenter?.didStartLoadingImageData(for: model)
    
    let model = self.model
    task = imageLoader.loadImageData(from: model.url) { [weak self] result in
      switch result {
      case let .success(data):
        self?.presenter?.didFinishLoadingImageData(with: data, for: model)
        
      case let .failure(error):
        self?.presenter?.didFinishLoadingImageData(with: error, for: model)
      }
    }
  }
  
  func didCancelImageRequest() {
    task?.cancel()
  }
}

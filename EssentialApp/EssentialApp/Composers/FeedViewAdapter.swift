//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/24.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialFeedPresentation

//这个逻辑放在组合层的原因是， [FeedImage]算是其它component的细节，应该放在这里, 万一以后换了其他的组件 搭配UI呢
final class FeedViewAdapter: ResourceView {
  
  private weak var controller: FeedViewController?
  private let imageLoader: FeedImageDataLoader
  
  init(controller: FeedViewController? = nil, imageLoader: FeedImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }
  
  func display(_ viewModel: FeedViewModel) {
    let cellControllers = viewModel.feed.map { model in
      let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
      let view = FeedImageCellController(delegate: adapter)
      adapter.presenter = FeedImagePresenter(
        view: WeakRefVirtualProxy(view),
        imageTransformer: UIImage.init)
      return view
    }
    controller?.display(cellControllers: cellControllers)
  }
}

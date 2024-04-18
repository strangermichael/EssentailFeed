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
  
  private weak var controller: ListViewController?
  private let imageLoader: FeedImageDataLoader
  private let selection: (FeedImage) -> Void
  private typealias LoadMorePresentationAdapter = ResourceLoaderPresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
  
  init(controller: ListViewController? = nil, imageLoader: FeedImageDataLoader, selection: @escaping (FeedImage) -> Void) {
    self.controller = controller
    self.imageLoader = imageLoader
    self.selection = selection
  }
  
  func display(_ viewModel: Paginated<FeedImage>) {
     let feedCellControllers = viewModel.feed.map { model in
      let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
      let view = FeedImageCellController(delegate: adapter, selection: { [weak self] in
        self?.selection(model)
      })
      adapter.presenter = FeedImagePresenter(
        view: WeakRefVirtualProxy(view),
        imageTransformer: UIImage.init)
      return CellController(id: model, view) //用和数据有关的id来标识
    }
    
    guard let loadMore = viewModel.loadMore else {
      controller?.display(feedCellControllers)
      return
    }
    let loadMoreAdapter = LoadMorePresentationAdapter(loadFuction: loadMore)
    let loadMoreCellController = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
    loadMoreAdapter.presenter = LoadResourcePresenter(resourceView: self,
                                                      loadingView: WeakRefVirtualProxy(loadMoreCellController),
                                                      errorView: WeakRefVirtualProxy(loadMoreCellController), mapper: { result in
      result
    })
    let loadMoreCellControllers = [CellController(id: UUID(), loadMoreCellController)]
    controller?.display(feedCellControllers, loadMoreCellControllers)
  }
}

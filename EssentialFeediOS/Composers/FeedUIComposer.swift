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
    let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    let feedController = FeedViewController(refreshController: refreshController)
    refreshController.onRefresh = adaptFeedToCellControllers(frowardingTo: feedController, loader: imageLoader)
    return feedController
  }
  
  private static func adaptFeedToCellControllers(frowardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    { [weak controller] feed in
      controller?.tableModel = feed.map { model in
        FeedImageCellController(model: model, imageLoader: loader)
      }
    }
  }
}

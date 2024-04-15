//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialFeedPresentation

public final class FeedUIComposer {
  private init() {}
  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader, selection: @escaping (FeedImage) -> Void = { _ in }) -> ListViewController {
    let feedLoader = MainQueueDispatchDecorator(decoratee: feedLoader)
    let imageLoader = MainQueueDispatchDecorator(decoratee: imageLoader)
    let presentationAdapter = ResourceLoaderPresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>(loadFuction: feedLoader.load)
    let feedController = makeWith(title: FeedPresenter.title)
    feedController.onRefresh = presentationAdapter.loadResource
    let presenter = LoadResourcePresenter<Paginated<FeedImage>, FeedViewAdapter>(resourceView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader, selection: selection),
                                                                        loadingView: WeakRefVirtualProxy(feedController),
                                                                        errorView: WeakRefVirtualProxy(feedController),
                                                                        mapper: { $0})
    presentationAdapter.presenter = presenter
    return feedController
  }
  
  private static func makeWith(title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! ListViewController
    feedController.title = title
    return feedController
  }
}

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
  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> ListViewController {
    let feedLoader = MainQueueDispatchDecorator(decoratee: feedLoader)
    let imageLoader = MainQueueDispatchDecorator(decoratee: imageLoader)
    let presentationAdapter = ResourceLoaderPresentationAdapter<[FeedImage], FeedViewAdapter>(loadFuction: feedLoader.load)
    let feedController = makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
    let presenter = LoadResourcePresenter<[FeedImage], FeedViewAdapter>(resourceView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
                                                                        loadingView: WeakRefVirtualProxy(feedController),
                                                                        errorView: WeakRefVirtualProxy(feedController),
                                                                        mapper: FeedPresenter.map)
    presentationAdapter.presenter = presenter
    return feedController
  }
  
  private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! ListViewController
    feedController.delegate = delegate
    feedController.title = title
    return feedController
  }
}

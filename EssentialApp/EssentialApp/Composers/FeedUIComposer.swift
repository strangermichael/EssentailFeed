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
  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let feedLoader = MainQueueDispatchDecorator(decoratee: feedLoader)
    let imageLoader = MainQueueDispatchDecorator(decoratee: imageLoader)
    let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
    let feedController = makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
    let presenter = LoadResourcePresenter<[FeedImage], FeedViewAdapter>(resourceView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
                                                                        loadingView: WeakRefVirtualProxy(feedController),
                                                                        errorView: WeakRefVirtualProxy(feedController),
                                                                        mapper: FeedPresenter.map)
    presentationAdapter.presenter = presenter
    return feedController
  }
  
  private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
    feedController.delegate = delegate
    feedController.title = title
    return feedController
  }
}

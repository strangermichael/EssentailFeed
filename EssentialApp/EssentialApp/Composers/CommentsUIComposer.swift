//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Shengjun Xia on 2024/4/13.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialFeedPresentation

public final class CommentsUIComposer {
  private init() {}
  public static func commentsComposedWith(commentsLoader: FeedLoader) -> ListViewController {
    let feedLoader = MainQueueDispatchDecorator(decoratee: commentsLoader)
    let presentationAdapter = ResourceLoaderPresentationAdapter<[FeedImage], FeedViewAdapter>(loadFuction: feedLoader.load)
    let feedController = makeWith(title: ImageCommentsPresenter.title)
    feedController.onRefresh = presentationAdapter.loadResource
    let presenter = LoadResourcePresenter<[FeedImage], FeedViewAdapter>(resourceView: FeedViewAdapter(controller: feedController, imageLoader: FeedImageDataLoaderMock()),
                                                                        loadingView: WeakRefVirtualProxy(feedController),
                                                                        errorView: WeakRefVirtualProxy(feedController),
                                                                        mapper: FeedPresenter.map)
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

//will remove
class FeedImageDataLoaderMock: FeedImageDataLoader {
  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
    FeedImageDataLoaderTaskMock()
  }
  
  
}

class FeedImageDataLoaderTaskMock: FeedImageDataLoaderTask {
  func cancel() {
    
  }
}

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
  public static func commentsComposedWith(commentsLoader: ImageCommentLoader) -> ListViewController {
    let commentsLoader = MainQueueDispatchDecorator(decoratee: commentsLoader)
    let presentationAdapter = ResourceLoaderPresentationAdapter<[ImageComment], CommentsViewAdapter>(loadFuction: commentsLoader.load)
    let feedController = makeWith(title: ImageCommentsPresenter.title)
    feedController.onRefresh = presentationAdapter.loadResource
    let presenter = LoadResourcePresenter<[ImageComment], CommentsViewAdapter>(resourceView: CommentsViewAdapter(controller: feedController),
                                                                               loadingView: WeakRefVirtualProxy(feedController),
                                                                               errorView: WeakRefVirtualProxy(feedController),
                                                                               mapper: { ImageCommentsPresenter.map($0) })
    presentationAdapter.presenter = presenter
    return feedController
  }
  
  private static func makeWith(title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Comment", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! ListViewController
    feedController.title = title
    return feedController
  }
}

final class CommentsViewAdapter: ResourceView {
  
  private weak var controller: ListViewController?
  
  init(controller: ListViewController? = nil) {
    self.controller = controller
  }
  
  func display(_ viewModel: ImageCommentsViewModel) {
    controller?.display(viewModel.comments.map({ viewModel in
      CellController(id: viewModel, ImageCommentCellController(model: viewModel))
    }))
  }
}

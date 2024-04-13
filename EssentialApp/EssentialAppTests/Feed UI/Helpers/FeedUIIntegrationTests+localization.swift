//
//  FeedViewControllerTest+localization.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/2/24.
//

import XCTest
import EssentialFeediOS
import EssentialFeed
import EssentialFeedPresentation

extension FeedUIIntegrationTests {
  private class DummyView: ResourceView {
    func display(_ viewModel: Any) { }
  }
  
  var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
  }
  
  var feedTitle: String {
    FeedPresenter.title
  }
  
  var commentsTitle: String {
    ImageCommentsPresenter.title
  }
}

//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/10.
//

import Foundation
import EssentialFeed

public class FeedPresenter {
  public static var title: String {
    NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed view")
  }
  
  public static func map(_ feed: [FeedImage]) -> FeedViewModel {
    FeedViewModel(feed: feed)
  }
}

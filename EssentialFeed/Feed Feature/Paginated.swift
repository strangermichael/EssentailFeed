//
//  Paginated.swift
//  EssentialFeedAPI
//
//  Created by Shengjun Xia on 2024/4/15.
//

import Foundation

public struct Paginated<Item> {
  public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void
  public let feed: [Item]
  public let loadMore: ((@escaping LoadMoreCompletion) -> ())? //如果不为空就表示可以load more, closure输入里传一个completion block告诉结束后做什么
  
  public init(feed: [Item], loadMore: ((@escaping LoadMoreCompletion) -> Void)? = nil) {
    self.feed = feed
    self.loadMore = loadMore
  }
}

extension Paginated: Equatable where Item: Equatable {
  public static func == (lhs: Paginated<Item>, rhs: Paginated<Item>) -> Bool {
    lhs.feed == rhs.feed
  }
}

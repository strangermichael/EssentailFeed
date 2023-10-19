//
//  FeedLoader.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/10/19.
//

import Foundation

/*
  Feed app要load Feed数据, 结果可能成功或失败
 */

enum LoadFeedResult {
  case success([FeedItem])
  case fail(Error)
}

protocol FeedLoader {
  func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}

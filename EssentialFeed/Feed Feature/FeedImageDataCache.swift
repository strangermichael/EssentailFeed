//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/25.
//

import Foundation

public protocol FeedImageDataCache {
  typealias Result = Swift.Result<Void, Error>

  func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}


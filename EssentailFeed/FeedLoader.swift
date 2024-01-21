//
//  FeedLoader.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/10/19.
//

import Foundation

public protocol FeedLoader {
  typealias Result = Swift.Result<[FeedImage], Error>
  func load(completion: @escaping (Result) -> Void)
}

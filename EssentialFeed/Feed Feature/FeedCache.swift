//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/25.
//

import Foundation

public protocol FeedCache {
  typealias SaveResult = Error?
  
  func save(items: [FeedImage], completion: @escaping (SaveResult) -> Void)
}

//
//  FeedItemMapper.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation

internal final class FeedItemMapper {
  private static var okCode = 200
  
  internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard response.statusCode == okCode,
          let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteFeedLoader.Error.invalidData
    }
    return root.items
  }
  
  private struct Root: Decodable {
    let items: [RemoteFeedItem]
  }
}

//
//  FeedItemMapper.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation

internal final class FeedItemMapper {
  private static var okCode = 200
  
  static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
    guard response.statusCode == okCode,
          let root = try? JSONDecoder().decode(Root.self, from: data) else {
      return .failure(RemoteFeedLoader.Error.invalidData)
    }
    return .success(root.feed)
  }
  
  private struct Root: Decodable {
    let items: [Item]
    
    var feed: [FeedItem] {
      items.map { $0.item }
    }
  }

  private struct Item: Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL
    
    var item: FeedItem {
      FeedItem(id: id, description: description, location: location, imageURL: image)
    }
  }

}

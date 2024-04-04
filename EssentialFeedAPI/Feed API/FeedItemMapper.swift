//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation
import EssentialFeed

internal final class FeedItemMapper {
  private static var okCode = 200
  
  internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
    guard response.statusCode == okCode,
          let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteFeedLoader.Error.invalidData
    }
    return root.images
  }
  
  private struct Root: Decodable {
    private let items: [RemoteFeedItem]
    
    private struct RemoteFeedItem: Decodable {
      let id: UUID
      let description: String?
      let location: String?
      let image: URL
    }
    
    var images: [FeedImage] {
      items.map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
  }
}

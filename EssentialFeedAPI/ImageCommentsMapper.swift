//
//  ImageCommentsMapper.swift
//  EssentialFeedAPI
//
//  Created by Shengjun Xia on 2024/4/4.
//

import Foundation
import EssentialFeed

internal final class ImageCommentsMapper {
  private static var okCode = 200
  private static func isOK(_ response: HTTPURLResponse) -> Bool {
    (200...299).contains(response.statusCode)
  }
  
  internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [ImageComment] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    guard Self.isOK(response),
          let root = try? decoder.decode(Root.self, from: data) else {
      throw RemoteImageCommentLoader.Error.invalidData
    }
    return root.comments
  }
  
  private struct Root: Decodable {
    private let items: [Item]
    
    private struct Item: Decodable {
      let id: UUID
      let message: String
      let created_at: Date
      let author: Author
    }
    
    private struct Author: Decodable {
      let username: String
    }
    
    var comments: [ImageComment] {
      items.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, userName: $0.author.username) }
    }
  }
}

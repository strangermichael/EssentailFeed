//
//  ImageCommentsMapper.swift
//  EssentialFeedAPI
//
//  Created by Shengjun Xia on 2024/4/4.
//

import Foundation

internal final class ImageCommentsMapper {
  private static var okCode = 200
  private static func isOK(_ response: HTTPURLResponse) -> Bool {
    (200...299).contains(response.statusCode)
  }
  
  internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard Self.isOK(response),
          let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteImageCommentLoader.Error.invalidData
    }
    return root.items
  }
  
  private struct Root: Decodable {
    let items: [RemoteFeedItem]
  }
}


//
//  FeedImage.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/10/18.
//

import Foundation

public struct FeedImage: Equatable {
  public let id: UUID
  public let description: String?
  public let location: String?
  public let url: URL
  
  public init(id: UUID, description: String?, location: String?, imageURL: URL) {
    self.id = id
    self.description = description
    self.location = location
    self.url = imageURL
  }
}

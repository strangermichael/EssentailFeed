//
//  ImageCommentsEndpoint.swift
//  EssentialFeedAPI
//
//  Created by Shengjun Xia on 2024/4/14.
//

import Foundation

public enum ImageCommentsEndpoint {
  case get(UUID)
  
  public func url(baseURL: URL) -> URL {
    switch self {
    case let .get(uuid):
      return baseURL.appending(path: "/v1/image/\(uuid)/comments")
    }
  }
}

//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/10.
//

import Foundation

public protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

public struct FeedErrorViewModel {
  public let message: String?
  
  static var noError: FeedErrorViewModel {
    .init(message: nil)
  }
  
  static func error(message: String) -> FeedErrorViewModel {
    .init(message: message)
  }
}

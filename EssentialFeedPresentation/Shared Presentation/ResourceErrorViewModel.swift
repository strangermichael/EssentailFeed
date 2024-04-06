//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/10.
//

import Foundation

public protocol ResourceErrorView {
  func display(_ viewModel: ResourceErrorViewModel)
}

public struct ResourceErrorViewModel {
  public let message: String?
  
  public static var noError: ResourceErrorViewModel {
    .init(message: nil)
  }
  
  public static func error(message: String) -> ResourceErrorViewModel {
    .init(message: message)
  }
}

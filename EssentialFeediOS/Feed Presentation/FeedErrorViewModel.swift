//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/3/9.
//

import Foundation

struct FeedErrorViewModel {
  let message: String?
  
  static var noError: FeedErrorViewModel {
    .init(message: nil)
  }
  
  static func error(message: String) -> FeedErrorViewModel {
    .init(message: message)
  }
}

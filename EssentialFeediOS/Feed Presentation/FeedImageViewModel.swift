//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/21.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
  let description: String?
  let location: String?
  let image: Image?
  let isLoading: Bool
  let shouldRetry: Bool
  
  var hasLocation: Bool {
    return location != nil
  }
}


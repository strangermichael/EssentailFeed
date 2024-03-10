//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/10.
//

import Foundation

public struct FeedViewModel {
  public let feed: [FeedImage]
}

public protocol FeedView {
  func display(viewModel: FeedViewModel)
}

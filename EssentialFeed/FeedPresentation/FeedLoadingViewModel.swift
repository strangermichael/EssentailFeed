//
//  FeedLoadingViewModel.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/10.
//

import Foundation

public struct FeedLoadingViewModel {
  public let isLoading: Bool
}

public protocol FeedLoadingView {
  func display(viewModel: FeedLoadingViewModel)
}

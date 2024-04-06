//
//  ResourceLoadingViewModel.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/10.
//

import Foundation

public struct ResourceLoadingViewModel {
  public let isLoading: Bool
}

public protocol ResourceLoadingView {
  func display(viewModel: ResourceLoadingViewModel)
}

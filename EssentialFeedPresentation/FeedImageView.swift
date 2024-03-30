//
//  FeedImageView.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/10.
//

import Foundation

public protocol FeedImageView {
  associatedtype Image
  
  func display(_ model: FeedImageViewModel<Image>)
}

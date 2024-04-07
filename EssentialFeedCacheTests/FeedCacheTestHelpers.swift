//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/1/1.
//

import Foundation
import EssentialFeed
import EssentialFeedCache

extension Date {
  func minusFeedCacheMaxAge() -> Date {
    adding(days: -feedCacheMaxAgeIndays)
  }
  
  private var feedCacheMaxAgeIndays: Int {
    7
  }
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
  let model = [uniqueImage(), uniqueImage()]
  let local = model.map {
    LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
  }
  return (model, local)
}

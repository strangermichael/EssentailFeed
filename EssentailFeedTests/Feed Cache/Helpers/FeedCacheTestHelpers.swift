//
//  FeedCacheTestHelpers.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2024/1/1.
//

import Foundation
import EssentailFeed

extension Date {
  func minusFeedCacheMaxAge() -> Date {
    adding(days: -feedCacheMaxAgeIndays)
  }
  
  private var feedCacheMaxAgeIndays: Int {
    7
  }
}

extension Date {
  //some days may not have 24 hours
  func adding(days: Int) -> Date {
    Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: Double) -> Date {
    self + seconds
  }
}

func uniqueImage() -> FeedImage {
  FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
  let model = [uniqueImage(), uniqueImage()]
  let local = model.map {
    LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
  }
  return (model, local)
}

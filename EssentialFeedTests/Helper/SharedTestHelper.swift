//
//  SharedTestHelper.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/1/1.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
  NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  URL(string: "http://url.com")!
}

func anyData() -> Data {
  Data("any data".utf8)
}

func uniqueImage() -> FeedImage {
  FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
}

func uniqueFeedImages() -> [FeedImage] {
  [uniqueImage(), uniqueImage()]
}

extension Date {
  //some days may not have 24 hours
  func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
    calendar.date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: Double) -> Date {
    self + seconds
  }
  
  func adding(minutes: Double) -> Date {
    self + minutes * 60
  }
}

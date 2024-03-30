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

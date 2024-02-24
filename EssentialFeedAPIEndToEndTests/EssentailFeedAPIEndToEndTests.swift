//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Shengjun Xia on 2023/12/20.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {
  
  func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
    switch getFeedResult() {
    case let .success(images):
      XCTAssertEqual(images.count, 8, "Exepected 8 items in the test data")
      XCTAssertEqual(images[0], expecedImage(at: 0))
      XCTAssertEqual(images[1], expecedImage(at: 1))
      XCTAssertEqual(images[2], expecedImage(at: 2))
      XCTAssertEqual(images[3], expecedImage(at: 3))
      XCTAssertEqual(images[4], expecedImage(at: 4))
      XCTAssertEqual(images[5], expecedImage(at: 5))
      XCTAssertEqual(images[6], expecedImage(at: 6))
      XCTAssertEqual(images[7], expecedImage(at: 7))
    case let .failure(error):
      XCTFail("Expeced successful feed result, got \(error) instead")
    default:
      XCTFail("Expeced successful feed result, got nothing")
    }
  }
  
  private func getFeedResult() -> FeedLoader.Result? {
    let testServerURL = URL(string: "https://www.essentialdeveloper.com/feed-case-study/test-api/feed")!
    let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    let loader = RemoteFeedLoader(client: client, url: testServerURL)
    let exp = expectation(description: "wait for load completion")
    trackForMemoryLeaks(client)
    trackForMemoryLeaks(loader)
    var recivedResult: FeedLoader.Result?
    loader.load { result in
      recivedResult = result
      exp.fulfill()
    }
    wait(for: [exp], timeout: 10.0)
    return recivedResult
  }
  
  private func expecedImage(at index: Int) -> FeedImage {
    FeedImage(id: id(at: index), description: description(at: index), location: location(at: index), imageURL: imageURL(at: index))
  }
  
  private func id(at index: Int) -> UUID {
    UUID(uuidString: [
      "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
      "BA298A85-6275-48D3-8315-9C8F7C1CD109",
      "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
      "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
      "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
      "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
      "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
      "F79BD7F8-063F-46E2-8147-A67635C3BB01",
    ][index])!
  }
  
  private func description(at index: Int) -> String? {
    [
      "Description 1",
      nil,
      "Description 3",
      nil,
      "Description 5",
      "Description 6",
      "Description 7",
      "Description 8",
    ][index]
  }
  
  private func location(at index: Int) -> String? {
    [
      "Location 1",
      "Location 2",
      nil,
      nil,
      "Location 5",
      "Location 6",
      "Location 7",
      "Location 8",
    ][index]
  }
  
  private func imageURL(at index: Int) -> URL {
    URL(string: [
      "https://url-1.com",
      "https://url-2.com",
      "https://url-3.com",
      "https://url-4.com",
      "https://url-5.com",
      "https://url-6.com",
      "https://url-7.com",
      "https://url-8.com",
    ][index])!
  }
}
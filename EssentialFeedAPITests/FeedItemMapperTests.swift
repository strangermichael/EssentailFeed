//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2023/10/19.
//

import XCTest
import EssentialFeed
import EssentialFeedAPI

//since already tested generic loader, so only need to test mapper
final class FeedItemMapperTests: XCTestCase {
  func test_map_throwsErrorOnNon200HTTPResponse() throws {
    let samples = [199, 201, 300, 400, 500]
    let json = makeItemsJSON([])
    try samples.forEach { code in
      XCTAssertThrowsError(
        try FeedItemMapper.map(json, .init(statusCode: code))
      )
    }
  }
  
  func test_map_throwsErrorOn200ResponeWithInvalidJSON() {
    let invalidJSON = Data("invalid json".utf8)
    XCTAssertThrowsError(try FeedItemMapper.map(invalidJSON, .init(statusCode: 200)))
  }
  
  func test_load_deliverNoItemsOn200ResponseWithEmptyJSONList() throws {
    let emptyListJSON = makeItemsJSON([])
    let result = try FeedItemMapper.map(emptyListJSON, .init(statusCode: 200))
    XCTAssertEqual(result, [])
  }
  
  func test_load_deliverItemsOn200HTTPResponseWithJSONItems() throws {
    let item1 = makeItem(id: UUID(),
                         description: nil,
                         location: nil,
                         imageURL: URL(string: "https://url.com")!)
    let item2 = makeItem(id: UUID(),
                         description: "a descrption",
                         location: "location",
                         imageURL: URL(string: "https://anotherUrl.com")!)
    let json = makeItemsJSON([item1, item2].map { $0.json })
    let result = try FeedItemMapper.map(json, .init(statusCode: 200))
    XCTAssertEqual(result, [item1.model, item2.model])
  }
  
  //MARK: - Helper
  func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
    let item = FeedImage(id: id,
                        description: description,
                        location: location,
                        imageURL: imageURL)
    let json = [
      "id": item.id.uuidString,
      "description": item.description,
      "location": item.location,
      "image": item.url.absoluteString
    ].compactMapValues { $0 }
    return (item, json)
  }
  
  private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let itemsJSON = [
      "items": items
    ]
    let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
    return json
  }
    
  func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
    .failure(error)
  }
}

private extension HTTPURLResponse {
  convenience init(statusCode: Int) {
    self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
  }
}

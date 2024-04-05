//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedAPITests
//
//  Created by Shengjun Xia on 2024/4/4.
//
 
import XCTest
import EssentialFeed
import EssentialFeedAPI

final class ImageCommentMapperTests: XCTestCase {
  //naming rule:  test + actionName + result
  func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
    let json = makeItemsJSON([])
    let samples = [199, 150, 300, 400, 500]
    try samples.enumerated().forEach { index, code in
      XCTAssertThrowsError(
        try ImageCommentsMapper.map(json, .init(statusCode: code))
      )
    }
  }
  
  func test_map_throwsErrorOn2xxResponeWithInvalidJSON() throws {
    let invalidData = Data("invalid json".utf8)
    let samples = [200, 201, 250, 280, 299]
    try samples.forEach { code in
      XCTAssertThrowsError(
        try ImageCommentsMapper.map(invalidData, .init(statusCode: code))
      )
    }
  }
  
  func test_map_deliverNoItemsOn2xxResponseWithEmptyJSONList() throws {
    let emptyListJSON = makeItemsJSON([])
    let samples = [200, 201, 250, 280, 299]
    try samples.forEach { code in
      let result = try ImageCommentsMapper.map(emptyListJSON, .init(statusCode: code))
      XCTAssertEqual(result, [])
    }
  }
  
  func test_map_deliverItemsOn200HTTPResponseWithJSONItems() throws {
    let item1 = makeItem(id: UUID(),
                         message: "a messgae",
                         createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                         userName: "a user name")
    let item2 = makeItem(id: UUID(),
                         message: "another message",
                         createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                         userName: "another user name")
    let json = makeItemsJSON([item1, item2].map { $0.json })
    let samples = [200, 201, 250, 280, 299]
    try samples.forEach { code in
      let result = try ImageCommentsMapper.map(json, .init(statusCode: code))
      XCTAssertEqual(result, [item1.model, item2.model])
    }
  }
  
  //MARK: - Helper
  //iso8601String: 不在工厂里做格式化原因是 时区变了测试可能会失败 所以传固定字符串
  func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), userName: String) -> (model: ImageComment, json: [String: Any]) {
    let item = ImageComment(id: id,
                            message: message,
                            createdAt: createdAt.date,
                            userName: userName)
    let json = [
      "id": id.uuidString,
      "message": message,
      "created_at": createdAt.iso8601String,
      "author": [
        "username": userName
      ]
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
}

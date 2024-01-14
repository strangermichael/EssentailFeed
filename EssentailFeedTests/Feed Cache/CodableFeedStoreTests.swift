//
//  CodableFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2024/1/13.
//

import XCTest
import EssentailFeed

class CodableFeedStore {
  private let storeURL: URL
  
  init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var localFeed: [LocalFeedImage] {
      feed.map { $0.local }
    }
  }
  
  private struct CodableFeedImage: Codable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL
    
    init(_ image: LocalFeedImage) {
      id = image.id
      description = image.description
      location = image.location
      url = image.url
    }
    
    var local: LocalFeedImage {
      LocalFeedImage(id: id, description: description, location: location, url: url)
    }
  }
  
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      completion(.empty)
      return
    }
    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(feed: cache.localFeed, timeStamp: cache.timestamp))
  }
  
  func insert(items: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let encoded = try! encoder.encode(Cache(feed: items.map { CodableFeedImage($0) }, timestamp: timeStamp))
    try! encoded.write(to: storeURL)
    completion(nil)
  }
}

final class CodableFeedStoreTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    setupEmptyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    setupEmptyStoreState()
  }
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    expect(sut, toRetrieve: .empty)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    expect(sut, toRetrieveTwice: .empty)
  }
  
  func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    insert(items: feed, timeStamp: timestamp, to: sut)
    expect(sut, toRetrieve: .found(feed: feed, timeStamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    insert(items: feed, timeStamp: timestamp, to: sut)
    expect(sut, toRetrieveTwice: .found(feed: feed, timeStamp: timestamp))
  }
  
  //- MARK: Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
    let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  private func insert(items: [LocalFeedImage], timeStamp: Date, to sut: CodableFeedStore) {
    let exp = expectation(description: "Wait for cache retrieval")
    sut.insert(items: items, timeStamp: timeStamp) { insertionError in
      XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retriveval")
    sut.retrieve { retrievedResult in
      switch (retrievedResult, expectedResult) {
      case (.empty, .empty):
        break
      case let (.found(expected), .found(retrieved)):
        XCTAssertEqual(expected.feed, retrieved.feed)
        XCTAssertEqual(expected.timeStamp, retrieved.timeStamp)
      default:
        XCTFail("Expected to retrieve \(expectedResult), but got \(retrievedResult) instead")
      }
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }
  
  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }
  
  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
  
  private func testSpecificStoreURL() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
  }
}

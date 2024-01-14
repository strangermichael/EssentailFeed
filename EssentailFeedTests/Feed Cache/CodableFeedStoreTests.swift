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
    do {
      let decoder = JSONDecoder()
      let cache = try decoder.decode(Cache.self, from: data)
      completion(.found(feed: cache.localFeed, timeStamp: cache.timestamp))
    } catch {
      completion(.failure(error))
    }
  }
  
  func insert(items: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    do {
      let encoder = JSONEncoder()
      let encoded = try encoder.encode(Cache(feed: items.map { CodableFeedImage($0) }, timestamp: timeStamp))
      try encoded.write(to: storeURL)
      completion(nil)
    } catch {
      completion(error)
    }
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
  
  func test_retrieveAfterInsertingToEmptyCache_deliversFoundValuesOnNonEmptyCache() {
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
  
  func test_retrieve_deliversFailureOnRetrievalError() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
    expect(sut, toRetrieve: .failure(anyNSError()))
  }
  
  func test_retrieve_hasNoSideEffectsOnFailure() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
    expect(sut, toRetrieveTwice: .failure(anyNSError()))
  }
  
  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()
    let firstInsertionError = insert(items: uniqueImageFeed().local, timeStamp: Date(), to: sut)
    XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
    
    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    let lasteInsertionError = insert(items: latestFeed, timeStamp: latestTimestamp, to: sut)
    XCTAssertNil(lasteInsertionError, "Expected to override cache successfully")
    expect(sut, toRetrieve: .found(feed: latestFeed, timeStamp: latestTimestamp))
  }
  
  func test_insert_deliversErrorOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")
    let sut = makeSUT(storeURL: invalidStoreURL)
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    let insertionError = insert(items: feed, timeStamp: timestamp, to: sut)
    XCTAssertNotNil(insertionError, "Expected cahce insertion to fail with an error")
  }
  
  //- MARK: Helpers
  private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  @discardableResult
  private func insert(items: [LocalFeedImage], timeStamp: Date, to sut: CodableFeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache retrieval")
    var insertionError: Error?
    sut.insert(items: items, timeStamp: timeStamp) { error in
      insertionError = error
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return insertionError
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retriveval")
    sut.retrieve { retrievedResult in
      switch (retrievedResult, expectedResult) {
      case (.empty, .empty),
           (.failure, .failure):
        break
      case let (.found(expectedFeed, expectedTimeStamp), .found(retrievedFeed, retrievedTimeStamp)):
        XCTAssertEqual(expectedFeed, retrievedFeed)
        XCTAssertEqual(expectedTimeStamp, retrievedTimeStamp)
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

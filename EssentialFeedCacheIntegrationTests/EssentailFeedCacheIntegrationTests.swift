//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Shengjun Xia on 2024/1/20.
//

import XCTest
import EssentialFeed
import EssentialFeedCache
import EssentialFeedCacheInfrastructure

final class EssentialFeedCacheIntegrationTests: XCTestCase {
  override func setUp() {
    super.setUp()
    setupEmptyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    undoStoreSideEffects()
  }
  
  func test_load_deliversNoItemsOnEmptyCache() {
    let sut = makeFeedLoader()
    expect(sut, toLoad: [])
  }
  
  func test_load_deliversItemsSavedOnASeparateInstance() {
    let sutToPerformSave = makeFeedLoader()
    let sutToPerformLoad = makeFeedLoader()
    let feed = uniqueFeedImages()
    save(feed, with: sutToPerformSave)
    expect(sutToPerformLoad, toLoad: feed)
  }
  
  func test_load_overridesItemsSavedOnASeparateInstance() {
    let sutToPerformFirstSave = makeFeedLoader()
    let sutToPerformLastSave = makeFeedLoader()
    let sutToPerformLoad = makeFeedLoader()

    let firstFeed = uniqueFeedImages()
    let lastFeed = uniqueFeedImages()
    save(firstFeed, with: sutToPerformFirstSave)
    save(lastFeed, with: sutToPerformLastSave)
    expect(sutToPerformLoad, toLoad: lastFeed)
  }
  
  // MARK: - LocalFeedImageDataLoader Tests
  
  func test_loadImageData_deliversSavedDataOnASeparateInstance() {
    let imageLoaderToPerformSave = makeImageLoader()
    let imageLoaderToPerformLoad = makeImageLoader()
    let feedLoader = makeFeedLoader()
    let image = uniqueImage()
    let dataToSave = anyData()
    
    save([image], with: feedLoader)
    save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
    
    expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
  }
  
  func test_saveImageData_overridesSavedImageDataOnASeparateInstance() {
    let imageLoaderToPerformFirstSave = makeImageLoader()
    let imageLoaderToPerformLastSave = makeImageLoader()
    let imageLoaderToPerformLoad = makeImageLoader()
    let feedLoader = makeFeedLoader()
    let image = uniqueImage()
    let firstImageData = Data("first".utf8)
    let lastImageData = Data("last".utf8)
    
    save([image], with: feedLoader)
    save(firstImageData, for: image.url, with: imageLoaderToPerformFirstSave)
    save(lastImageData, for: image.url, with: imageLoaderToPerformLastSave)

    expect(imageLoaderToPerformLoad, toLoad: lastImageData, for: image.url)
  }

  
  //MARK: - helpers
  private func makeFeedLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedImageDataLoader(store: store)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
    let saveExp = expectation(description: "Wait for save completion")
    loader.save(items: feed) { saveError in
      XCTAssertNil(saveError, "Expected to save feed successfully")
      saveExp.fulfill()
    }
    wait(for: [saveExp], timeout: 1.0)
  }
  
  private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
    let saveExp = expectation(description: "Wait for save completion")
    loader.save(data, for: url) { result in
      if case let Result.failure(error) = result {
        XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
      }
      saveExp.fulfill()
    }
    wait(for: [saveExp], timeout: 1.0)
  }
  
  private func expect(_ sut: LocalFeedLoader, toLoad expecedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load { result in
      switch result {
      case let .success(loadedFeed):
        XCTAssertEqual(loadedFeed, expecedFeed)
      case let .failure(error):
        XCTFail("Expected to get successful feed result, but got \(error) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    _ = sut.loadImageData(from: url) { result in
      switch result {
      case let .success(loadedData):
        XCTAssertEqual(loadedData, expectedData, file: file, line: line)
        
      case let .failure(error):
        XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
      }
      
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private func testSpecificStoreURL() -> URL {
    cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }
  
  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
  
  private func noDeletePermissionURL() -> URL {
      return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
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
}

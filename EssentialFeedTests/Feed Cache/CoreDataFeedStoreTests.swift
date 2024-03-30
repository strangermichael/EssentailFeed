//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/1/19.
//

import XCTest
import EssentialFeed
import EssentialFeedCache
import EssentialFeedCacheInfrastructure

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
  }
  
  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()
    assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
  }
    
  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()
    assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
  }
  
  func test_insert_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
  }
  
  func test_insert_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
  }
    
  func test_delete_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
  }
  
  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
  }
  
  func test_delete_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
  }
  
  func test_delete_emptiesPreviouslyInsertedCached() {
    let sut = makeSUT()
    assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
  }
  
  func test_storeSideEffects_runSerially() {
    let sut = makeSUT()
    assertThatSideEffectsRunSerially(on: sut)
  }
  
  //MARK: - helper
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = URL(fileURLWithPath: "/dev/null") //won't store in disk, but still got data in memory
    let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
}

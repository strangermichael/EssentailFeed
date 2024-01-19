//
//  CoreDataFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2024/1/19.
//

import XCTest
import EssentailFeed
import CoreData

class CoreDataFeedStore: FeedStore {
  public init() {
    
  }
  
  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    
  }
  
  public func insert(items: [EssentailFeed.LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
    
  }
  
  public func retrieve(completion: @escaping RetrievalCompletion) {
    completion(.empty)
  }
}

private class ManagedCache: NSManagedObject {
  @NSManaged var timestamp: Date
  @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var imageDescription: String?
  @NSManaged var location: String?
  @NSManaged var url: URL
  @NSManaged var cache: ManagedCache
}

final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStoreSpec {
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
  }
  
  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    
  }
  
  func test_retrieve_deliversFailureOnRetrievalError() {
    
  }
  
  func test_retrieve_hasNoSideEffectsOnFailure() {
    
  }
  
  func test_insert_overridesPreviouslyInsertedCacheValues() {
    
  }
  
  func test_insert_deliversNoErrorOnEmptyCache() {
    
  }
  
  func test_insert_deliversNoErrorOnNonEmptyCache() {
    
  }
  
  func test_insert_deliversErrorOnInsertionError() {
    
  }
  
  func test_insert_hasNoSideEffectsOnInsertionError() {
    
  }
  
  func test_delete_deliversNoErrorOnEmptyCache() {
    
  }
  
  func test_delete_hasNoSideEffectsOnEmptyCache() {
    
  }
  
  func test_delete_deliversNoErrorOnNonEmptyCache() {
    
  }
  
  func test_delete_emptiesPreviouslyInsertedCached() {
    
  }
  
  func test_delete_deliversErrorOnDeletionError() {
    
  }
  
  func test_delete_hasNoSideEffectsOnDeletionError() {
    
  }
  
  
  func test_storeSideEffects_runSerially() {
    
  }
  
  //MARK: - helper
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
    let sut = CoreDataFeedStore()
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
}
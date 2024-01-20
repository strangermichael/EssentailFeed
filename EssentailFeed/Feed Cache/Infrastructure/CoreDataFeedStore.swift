//
//  CoreDataFeedStore.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2024/1/19.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
  private let container: NSPersistentContainer
  private let context: NSManagedObjectContext
  
  public init(storeURL: URL, bundle: Bundle = .main) throws {
    container = try NSPersistentContainer.load(modelName: "FeedStore", storeURL: storeURL, in: bundle)
    context = container.newBackgroundContext()
  }
  
  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    performAndWait { context in
      do {
        try ManagedCache.find(in: context).map(context.delete).map(context.save)
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }
  
  public func insert(items: [EssentailFeed.LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
    performAndWait { context in
      do {
        let managedCache = try ManagedCache.newUniqueInstance(in: context)
        managedCache.timestamp = timeStamp
        managedCache.feed = ManagedFeedImage.images(from: items, in: context)
        
        try context.save()
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }
  
  public func retrieve(completion: @escaping RetrievalCompletion) {
    performAndWait { context in
      do {
        if let cache = try ManagedCache.find(in: context) {
          completion(.found(feed: cache.localFeed, timeStamp: cache.timestamp))
        } else {
          completion(.empty)
        }
      } catch {
        completion(.failure(error))
      }
    }
  }
  
  private func performAndWait(_ action: @escaping (NSManagedObjectContext) -> Void) {
    let context = self.context
    //if use perform here will frequently crash when run EssentailFeedCacheIntegrationTests
    context.perform { action(context) }
  }
}

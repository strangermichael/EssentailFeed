//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/21.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
  
  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    perform { context in
      do {
        try ManagedCache.find(in: context).map(context.delete).map(context.save)
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }
  
  public func insert(items: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    perform { context in
      do {
        let managedCache = try ManagedCache.newUniqueInstance(in: context)
        managedCache.timestamp = timestamp
        managedCache.feed = ManagedFeedImage.images(from: items, in: context)
        
        try context.save()
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }
  
  public func retrieve(completion: @escaping RetrievalCompletion) {
    perform { context in
      do {
        if let cache = try ManagedCache.find(in: context) {
          completion(.success(.some(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp))))
        } else {
          completion(.success(.none))
        }
      } catch {
        completion(.failure(error))
      }
    }
  }
}

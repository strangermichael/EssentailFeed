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
    
  }
  
  public func insert(items: [EssentailFeed.LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
    let context = self.context
    context.perform {
      do {
        let managedCache = ManagedCache(context: context)
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
    let context = self.context
    context.perform {
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
}

private extension NSManagedObjectModel {
  static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
    return bundle
      .url(forResource: name, withExtension: "momd")
      .flatMap { NSManagedObjectModel(contentsOf: $0) }
  }
}

private extension NSPersistentContainer {
  enum LoadingError: Swift.Error {
    case modelNotFound
    case failedToLoadPersistentStores(Swift.Error)
  }

  static func load(modelName name: String, storeURL: URL, in bundle: Bundle) throws -> NSPersistentContainer {
    guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
      throw LoadingError.modelNotFound
    }

    let description = NSPersistentStoreDescription(url: storeURL)
    let container = NSPersistentContainer(name: name, managedObjectModel: model)
    container.persistentStoreDescriptions = [description]
    var loadError: Swift.Error?
    container.loadPersistentStores { loadError = $1 }
    try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }

    return container
  }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
  @NSManaged var timestamp: Date
  @NSManaged var feed: NSOrderedSet
  static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
    let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
    request.returnsObjectsAsFaults = false
    return try context.fetch(request).first
  }
  
  var localFeed: [LocalFeedImage] {
    return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
  }
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var imageDescription: String?
  @NSManaged var location: String?
  @NSManaged var url: URL
  @NSManaged var cache: ManagedCache
  
  static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
    return NSOrderedSet(array: localFeed.map { local in
      let managed = ManagedFeedImage(context: context)
      managed.id = local.id
      managed.imageDescription = local.description
      managed.location = local.location
      managed.url = local.url
      return managed
    })
  }
  
  var local: LocalFeedImage {
    return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
  }
}
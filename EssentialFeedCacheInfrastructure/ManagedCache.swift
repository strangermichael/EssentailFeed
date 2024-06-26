//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/1/19.
//

import CoreData
import EssentialFeedCache

@objc(ManagedCache)
internal class ManagedCache: NSManagedObject {
  @NSManaged var timestamp: Date
  @NSManaged var feed: NSOrderedSet
  static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
    let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
    request.returnsObjectsAsFaults = false
    return try context.fetch(request).first
  }
}

extension ManagedCache {
  static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
    try find(in: context).map(context.delete)
    return ManagedCache(context: context)
  }
  
  var localFeed: [LocalFeedImage] {
    return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
  }
}

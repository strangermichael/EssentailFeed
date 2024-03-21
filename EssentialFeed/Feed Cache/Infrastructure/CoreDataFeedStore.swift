//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/1/19.
//

import Foundation
import CoreData

public class CoreDataFeedStore {
  private let container: NSPersistentContainer
  private let context: NSManagedObjectContext
  
  public init(storeURL: URL, bundle: Bundle = .main) throws {
    container = try NSPersistentContainer.load(modelName: "FeedStore", storeURL: storeURL, in: bundle)
    context = container.newBackgroundContext()
  }
  
  public func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
    let context = self.context
    context.perform { action(context) }
  }
}

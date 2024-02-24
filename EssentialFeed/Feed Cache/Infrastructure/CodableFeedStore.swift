//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/1/14.
//

import Foundation

public class CodableFeedStore: FeedStore {
  private let storeURL: URL
  private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
  
  public init(storeURL: URL) {
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
  
  public func retrieve(completion: @escaping RetrievalCompletion) {
    let storeURL = self.storeURL
    queue.async {
      guard let data = try? Data(contentsOf: storeURL) else {
        completion(.success(.none))
        return
      }
      do {
        let decoder = JSONDecoder()
        let cache = try decoder.decode(Cache.self, from: data)
        completion(.success(.some(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp))))
      } catch {
        completion(.failure(error))
      }
    }
  }
  
  public func insert(items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    let storeURL = self.storeURL
    queue.async(flags: .barrier) {
      do {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(Cache(feed: items.map { CodableFeedImage($0) }, timestamp: timestamp))
        try encoded.write(to: storeURL)
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }
  
  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    let storeURL = self.storeURL
    queue.async(flags: .barrier) {
      guard FileManager.default.fileExists(atPath: storeURL.path(percentEncoded: true)) else {
        completion(nil)
        return
      }
      do {
        try FileManager.default.removeItem(at: storeURL)
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }
}

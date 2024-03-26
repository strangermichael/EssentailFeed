//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by Shengjun Xia on 2024/3/26.
//

import UIKit
import EssentialFeed

class DebuggingSceneDelegate: SceneDelegate {
  
  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if CommandLine.arguments.contains("-reset") {
      try? FileManager.default.removeItem(at: localStoreURL)
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }
  
  
  override func makeRemoteClient() -> HTTPClient {
    if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
      return AlwaysFailingHTTPClinet()
    }
    return super.makeRemoteClient()
  }
  
  private class AlwaysFailingHTTPClinet: HTTPClient {
    private class Task: HTTPClientTask {
      func cancel() {
        
      }
    }
    
    func get(from url: URL, completion: @escaping (AlwaysFailingHTTPClinet.Result) -> Void) -> HTTPClientTask {
      completion(.failure(NSError(domain: "offline", code: 0)))
      return Task()
    }
  }
}


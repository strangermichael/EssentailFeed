//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Shengjun Xia on 2024/3/22.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData
import EssentialFeedAPI
import EssentialFeedCache
import EssentialFeedCacheInfrastructure

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()
  
  private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
  
  private lazy var store: FeedStore & FeedImageDataStore = {
    try! CoreDataFeedStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite"),
                           bundle: Bundle(for: CoreDataFeedStore.self))
  }()
  
  private lazy var localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
  
  private lazy var navigationController: UINavigationController = {
    //这个ur是最新的，视频里url图片下载不了
    let remoteURL = FeedEndpoint.get.url(baseURL: baseURL)!
    let remoteFeedLoader = RemoteFeedLoader(client: httpClient, url: remoteURL)
    let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
    let localImageLoader = LocalFeedImageDataLoader(store: store)
    let feedViewController = FeedUIComposer.feedComposedWith(feedLoader:
                                                              FeedLoaderWithFallbackComposite(primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader),
                                                                                              fallback: localFeedLoader),
                                                             imageLoader: FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader,
                                                                                                                   fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)),
    selection: showComments)
    return UINavigationController(rootViewController: feedViewController)
  }()
  
  convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
    self.init()
    self.httpClient = httpClient
    self.store = store
  }
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let scene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: scene)
    configureWindow()
  }
  
  func configureWindow() {
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }
  
  private func showComments(image: FeedImage) {
    let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
    let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
    navigationController.pushViewController(comments, animated: true)
  }
  
  private func makeRemoteCommentsLoader(url: URL) -> RemoteImageCommentLoader {
    RemoteImageCommentLoader(client: httpClient, url: url)
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    localFeedLoader.validateCache()
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }


}

extension RemoteLoader: FeedLoader where Resource == Paginated<FeedImage> {}
extension RemoteLoader: ImageCommentLoader where Resource == [ImageComment] {}

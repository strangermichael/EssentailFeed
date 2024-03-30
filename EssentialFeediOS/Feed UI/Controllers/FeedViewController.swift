//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/3.
//

import UIKit
import EssentialFeed
import EssentialFeedPresentation

public protocol FeedViewControllerDelegate: AnyObject {
  func didRequestFeedRefresh()
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
  public var delegate: FeedViewControllerDelegate?
  private var tableModel: [FeedImageCellController] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  @IBOutlet private(set) public weak var errorView: ErrorView!
  
  private var loadingControllers: [IndexPath: FeedImageCellController] = [:]
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    tableView.prefetchDataSource = self
    refresh()
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.sizeTableHeaderToFit()
  }
  
  @IBAction private func refresh() {
    delegate?.didRequestFeedRefresh()
  }
  
  public func display(cellControllers: [FeedImageCellController]) {
    loadingControllers = [:]
    tableModel = cellControllers
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    tableModel.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cellController(forRowAt: indexPath).view(in: tableView)
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //数据源变了之后才reload data然后会调用end display，但是比如数据减少了 可能导致index访问越界crash, 或者访问到错误的数据
    cancelCellControllerLoad(forRowAt: indexPath)
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      cellController(forRowAt: indexPath).preload()
    }
  }
  
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(cancelCellControllerLoad)
  }
  
  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    let controller = tableModel[indexPath.row]
    loadingControllers[indexPath] = controller
    return controller
  }
  
  private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
    loadingControllers[indexPath]?.cancelLoad()
    loadingControllers[indexPath] = nil
  }
  
  public func display(viewModel: FeedLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }
  
  public func display(_ viewModel: FeedErrorViewModel) {
    errorView.message = viewModel.message
  }
}

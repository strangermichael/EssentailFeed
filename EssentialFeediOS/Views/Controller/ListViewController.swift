//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/3.
//

import UIKit
import EssentialFeed
import EssentialFeedPresentation

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
  private var tableModel: [CellController] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  private(set) public var errorView = ErrorView()
  
  private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
    .init(tableView: tableView) { tableView, indexPath, controller in
      controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
    }
  }()
  
  public var onRefresh: (() -> Void)?
  private var onViewIsAppearing: ((ListViewController) -> Void)?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = dataSource
    configureErrorView()
    onViewIsAppearing = { vc in
      vc.onViewIsAppearing = nil
      vc.refresh()
    }
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    onViewIsAppearing?(self)
  }

  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.sizeTableHeaderToFit()
  }
  
  @IBAction private func refresh() {
    onRefresh?()
  }
  
  public func display(cellControllers: [CellController]) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
    snapshot.appendSections([0])
    snapshot.appendItems(cellControllers, toSection: 0)
    if #available(iOS 15.0, *) {
      dataSource.applySnapshotUsingReloadData(snapshot) //不加这个测试过不了lol
    } else {
      dataSource.apply(snapshot)
    }
  }
  
  public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let dl = cellController(at: indexPath)?.delegate
    dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //数据源变了之后才reload data然后会调用end display，但是比如数据减少了 可能导致index访问越界crash, 或者访问到错误的数据
    let dl = cellController(at: indexPath)?.delegate
    dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
  }
  
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach{ indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
  }
  
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dl = cellController(at: indexPath)?.delegate
    dl?.tableView?(tableView, didSelectRowAt: indexPath)
  }
  
  private func configureErrorView() {
    let container = UIView()
    container.backgroundColor = .clear
    container.addSubview(errorView)
    
    errorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
      errorView.topAnchor.constraint(equalTo: container.topAnchor),
      container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
    ])
    
    tableView.tableHeaderView = container
    
    errorView.onHide = { [weak self] in
      self?.tableView.beginUpdates()
      self?.tableView.sizeTableHeaderToFit()
      self?.tableView.endUpdates()
    }
  }
  
  private func cellController(at indexPath: IndexPath) -> CellController? {
    dataSource.itemIdentifier(for: indexPath)
  }
  
  
  public func display(viewModel: ResourceLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    errorView.message = viewModel.message
  }
}

//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/3.
//

import UIKit
import EssentailFeed

final public class FeedViewController: UITableViewController {
  private var loader: FeedLoader?
  private var tableModel: [FeedImage] = []
  
  public init(loader: FeedLoader) {
    super.init(nibName: nil, bundle: nil)
    self.loader = loader
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    load()
  }
  
  @objc private func load() {
    refreshControl?.beginRefreshing()
    loader?.load(completion: {[weak self] result in
      switch result {
      case .success(let images):
        self?.tableModel = images
        self?.tableView.reloadData()
      case .failure:
        break
      }
      self?.refreshControl?.endRefreshing()
    })
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    tableModel.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellModel = tableModel[indexPath.row]
    let cell = FeedImageCell()
    cell.locationContainer.isHidden = cellModel.location == nil
    cell.locationLabel.text = cellModel.location
    cell.descriptionLabel.text = cellModel.description
    return cell
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

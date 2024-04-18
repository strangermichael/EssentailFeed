//
//  LoadMoreCellController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/4/15.
//

import UIKit
import EssentialFeedPresentation

public class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
  let loadMoreCell = LoadMoreCell()
  
  private let callback: () -> Void
  
  public init(callback: @escaping () -> Void) {
    self.callback = callback
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    loadMoreCell
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard loadMoreCell.isLoading == false else { return }
    callback()
  }
}


extension LoadMoreCellController: ResourceLoadingView {
  public func display(viewModel: EssentialFeedPresentation.ResourceLoadingViewModel) {
    loadMoreCell.isLoading = viewModel.isLoading
  }
}

extension LoadMoreCellController: ResourceErrorView {
  public func display(_ viewModel: EssentialFeedPresentation.ResourceErrorViewModel) {
    loadMoreCell.message = viewModel.message
  }
}

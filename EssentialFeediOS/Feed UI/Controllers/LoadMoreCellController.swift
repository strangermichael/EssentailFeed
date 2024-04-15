//
//  LoadMoreCellController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/4/15.
//

import UIKit
import EssentialFeedPresentation

public class LoadMoreCellController: NSObject, UITableViewDataSource {
  let cell = LoadMoreCell()
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell
  }
}


extension LoadMoreCellController: ResourceLoadingView {
  public func display(viewModel: EssentialFeedPresentation.ResourceLoadingViewModel) {
    cell.isLoading = viewModel.isLoading
  }
}

extension LoadMoreCellController: ResourceErrorView {
  public func display(_ viewModel: EssentialFeedPresentation.ResourceErrorViewModel) {
    cell.message = viewModel.message
  }
}

//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/4/9.
//

import UIKit
import EssentialFeedPresentation

public class ImageCommentCellController: NSObject, UITableViewDataSource {
  private let model: ImageCommentViewModel
  
  public init(model: ImageCommentViewModel) {
    self.model = model
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: ImageCommentCell = tableView.dequeueReusableCell()
    cell.messageLabel.text = model.message
    cell.userNameLabel.text = model.username
    cell.dateLabel.text = model.date
    return cell
  }
}

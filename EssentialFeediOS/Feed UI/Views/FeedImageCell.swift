//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/8.
//

import UIKit

public class FeedImageCell: UITableViewCell {
  @IBOutlet private(set) public var locationContainer: UIView!
  @IBOutlet private(set) public var locationLabel: UILabel!
  @IBOutlet private(set) public var descriptionLabel: UILabel!
  @IBOutlet private(set) public var feedImageContainer: UIView!
  @IBOutlet private(set) public var feedImageView: UIImageView!
  @IBOutlet private(set) public var feedImageRetryButton: UIButton!
  
  public var onRetry: (() -> Void)?
  
  @IBAction func retryButtonTapped() {
    onRetry?()
  }
}

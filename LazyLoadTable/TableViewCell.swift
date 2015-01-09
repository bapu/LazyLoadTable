//
//  TableViewCell.swift
//  LazyLoadTable
//
//  Created by Baidyanath on 1/9/15.
//  Copyright (c) 2015 Baidyanath. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
@IBOutlet weak var lazyImageView: UIImageView!
@IBOutlet weak var txtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lazyImageView.layer.borderColor = UIColor.blueColor().CGColor
        self.lazyImageView.layer.borderWidth = 1
        self.separatorInset = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

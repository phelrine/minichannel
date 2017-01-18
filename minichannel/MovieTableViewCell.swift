//
//  MovieTableViewCell.swift
//  minichannel
//
//  Created by nagasaka.shogo on 1/19/17.
//  Copyright © 2017 jp.ne.donuts. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        thumbnailView.image = nil
    }
}

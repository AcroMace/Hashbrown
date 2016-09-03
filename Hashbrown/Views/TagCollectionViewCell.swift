//
//  TagCollectionViewCell.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit
import Haneke

struct TagCollectionCellViewModel {
    let tag: String
    let imageURL: String?
}

class TagCollectionViewCell: UICollectionViewCell {

    static let nibName = String(TagCollectionViewCell)
    static let reuseIdentifier = String(TagCollectionViewCell)

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.grayColor()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset the data
        tagLabel.text = ""
        backgroundImageView.image = nil
    }

    func configure(viewModel: TagCollectionCellViewModel) {
        tagLabel.text = viewModel.tag
        if let imageURL = viewModel.imageURL, url = NSURL(string: imageURL) {
            backgroundImageView.hnk_setImageFromURL(url)
        }
    }

}

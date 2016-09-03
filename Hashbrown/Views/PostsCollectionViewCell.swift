//
//  PostsCollectionViewCell.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-02.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit
import Haneke

struct PostsCollectionCellViewModel {
    let post: InstagramPost
}

class PostsCollectionViewCell: UICollectionViewCell {

    static let nibName = String(PostsCollectionViewCell)
    static let reuseIdentifier = String(PostsCollectionViewCell)

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.grayColor()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    func configure(viewModel: PostsCollectionCellViewModel) {
        if let imageURL = NSURL(string: viewModel.post.imageURL) {
            imageView.hnk_setImageFromURL(imageURL)
        }
    }

}

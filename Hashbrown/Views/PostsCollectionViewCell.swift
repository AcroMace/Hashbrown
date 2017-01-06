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

    static let nibName = String(describing: PostsCollectionViewCell.self)
    static let reuseIdentifier = String(describing: PostsCollectionViewCell.self)

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.gray
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    func configure(_ viewModel: PostsCollectionCellViewModel) {
        if let imageURL = URL(string: viewModel.post.imageURL) {
            imageView.hnk_setImageFromURL(imageURL)
        }
    }

}

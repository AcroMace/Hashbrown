//
//  TagSearchCollectionViewCell.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-05.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

protocol TagSearchCollectionViewCellDelegate {

    /**
     Called when the user presses the add button on a tag search result

     - parameter tag: The name of the tag
     */
    func didTapAddTagButton(tag: String)

}

struct TagSearchCollectionCellViewModel {

    let tagName: String
    let tagMediaCount: Int
    let imageURL: String?

}

class TagSearchCollectionViewCell: UICollectionViewCell {

    static let nibName = String(TagSearchCollectionViewCell)
    static let reuseIdentifier = String(TagSearchCollectionViewCell)

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    var viewModel: TagSearchCollectionCellViewModel?
    var delegate: TagSearchCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.grayColor()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset the data
        imageView.image = nil
        tagLabel.text = ""
    }

    func configure(viewModel: TagSearchCollectionCellViewModel) {
        self.viewModel = viewModel
        tagLabel.text = "#\(viewModel.tagName)"
        numberOfPostsLabel.text = "\(viewModel.tagMediaCount) Posts"
        if let imageURL = viewModel.imageURL, url = NSURL(string: imageURL) {
            imageView.hnk_setImageFromURL(url)
        }
    }

    @IBAction func didTapAddButton(sender: AnyObject) {
        guard let `viewModel` = viewModel else { return }
        print("TEST: didTapAddButton")
        delegate?.didTapAddTagButton(viewModel.tagName)
    }

    override func canBecomeFocused() -> Bool {
        return false
    }

}

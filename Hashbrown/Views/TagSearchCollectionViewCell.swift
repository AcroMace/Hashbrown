//
//  TagSearchCollectionViewCell.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-05.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

struct TagSearchCollectionCellViewModel {

    let tagName: String
    let tagMediaCount: Int
    let imageURL: String?
    let isAlreadyAdded: Bool
    let row: Int // From the indexPath

}

class TagSearchCollectionViewCell: UICollectionViewCell {

    static let nibName = String(TagSearchCollectionViewCell)
    static let reuseIdentifier = String(TagSearchCollectionViewCell)

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var addButtonBackground: UIView!
    @IBOutlet weak var addButtonLabel: UILabel!

    var viewModel: TagSearchCollectionCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.grayColor()

        addButtonBackground.layer.borderColor = UIColor.whiteColor().CGColor
        addButtonBackground.layer.borderWidth = 2
        addButtonBackground.layer.shadowColor = UIColor.blackColor().CGColor
        addButtonBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
        addButtonLabel.shadowOffset = CGSize(width: 0, height: 1)
        setButtonAsNotSelected()
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

        // Alternate placeholder background colours
        backgroundColor = viewModel.row % 2 == 0 ? UIColor.lightGrayColor() : UIColor.grayColor()

        // Set the selection state
        if viewModel.isAlreadyAdded {
            setButtonAsSelected()
        } else {
            setButtonAsNotSelected()
        }

        // Set the image
        if let imageURL = viewModel.imageURL, url = NSURL(string: imageURL) {
            imageView.hnk_setImageFromURL(url)
        }
    }

    private func setButtonAsSelected() {
        addButtonBackground.backgroundColor = UIColor.whiteColor()
        addButtonLabel.shadowColor = UIColor.clearColor()
        addButtonLabel.textColor = UIColor.blackColor()
        addButtonLabel.text = "Added"
    }

    private func setButtonAsNotSelected() {
        addButtonBackground.backgroundColor = UIColor.clearColor()
        addButtonLabel.shadowColor = UIColor.blackColor()
        addButtonLabel.textColor = UIColor.whiteColor()
        addButtonLabel.text = "Add"
    }

}

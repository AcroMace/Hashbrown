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

    static let nibName = String(describing: TagSearchCollectionViewCell.self)
    static let reuseIdentifier = String(describing: TagSearchCollectionViewCell.self)

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var addButtonBackground: UIView!
    @IBOutlet weak var addButtonLabel: UILabel!

    var viewModel: TagSearchCollectionCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.gray

        addButtonBackground.layer.borderColor = UIColor.white.cgColor
        addButtonBackground.layer.borderWidth = 2
        addButtonBackground.layer.shadowColor = UIColor.black.cgColor
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

    func configure(_ viewModel: TagSearchCollectionCellViewModel) {
        self.viewModel = viewModel
        tagLabel.text = "#\(viewModel.tagName)"
        numberOfPostsLabel.text = "\(viewModel.tagMediaCount) Posts"

        // Alternate placeholder background colours
        backgroundColor = viewModel.row % 2 == 0 ? UIColor.lightGray : UIColor.gray

        // Set the selection state
        if viewModel.isAlreadyAdded {
            setButtonAsSelected()
        } else {
            setButtonAsNotSelected()
        }

        // Set the image
        if let imageURL = viewModel.imageURL, let url = URL(string: imageURL) {
            imageView.hnk_setImageFromURL(url)
        }
    }

    fileprivate func setButtonAsSelected() {
        addButtonBackground.backgroundColor = UIColor.white
        addButtonLabel.shadowColor = UIColor.clear
        addButtonLabel.textColor = UIColor.black
        addButtonLabel.text = "Added"
    }

    fileprivate func setButtonAsNotSelected() {
        addButtonBackground.backgroundColor = UIColor.clear
        addButtonLabel.shadowColor = UIColor.black
        addButtonLabel.textColor = UIColor.white
        addButtonLabel.text = "Add"
    }

}

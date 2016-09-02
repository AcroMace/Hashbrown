//
//  TagsCollectionViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

struct TagsCollectionViewModel {
    let authToken: String
}

class TagsCollectionViewController: UIViewController {

    static let storyboardName = String(TagsCollectionViewController)
    static let numberOfColumns: CGFloat = 3

    @IBOutlet weak var collectionView: UICollectionView!

    private var viewModel: TagsCollectionViewModel!
    private var tags = ["abc", "def", "ghi"]

    class func createInstance(authToken: String) -> TagsCollectionViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: TagsCollectionViewController.self))
        let instance = storyboard.instantiateInitialViewController() as! TagsCollectionViewController
        instance.viewModel = TagsCollectionViewModel(authToken: authToken)
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        registerTagCollectionViewCellNib()

        print("Loaded TagsCollectionViewController with auth token \(viewModel.authToken)")
        collectionView.reloadData()
    }

    private func registerTagCollectionViewCellNib() {
        let nib = UINib(nibName: TagCollectionViewCell.nibName, bundle: nibBundle)
        let reuseIdentifier = TagCollectionViewCell.reuseIdentifier
        collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

}

// MARK: UICollectionViewDelegate

extension TagsCollectionViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = floor(view.frame.width / TagsCollectionViewController.numberOfColumns)
        return CGSize(width: width, height: width)
    }

    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

}

// MARK: UICollectionViewDataSource

extension TagsCollectionViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TagCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as? TagCollectionViewCell else {
            print("ERROR: Could not dequeue TagCollectionViewCell")
            return TagCollectionViewCell()
        }

        // Configure the cell
        guard tags.count > indexPath.row else {
            return TagCollectionViewCell()
        }
        let viewModel = TagCollectionCellViewModel(tag: tags[indexPath.row], imageURL: nil)
        cell.configure(viewModel)

        return cell
    }

}

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

    private let instagramService = InstagramService()

    private var viewModel: TagsCollectionViewModel!
    private var tags = [InstagramTag]()

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

        log.debug("Loaded TagsCollectionViewController with auth token \(viewModel.authToken)")
        reloadData()
    }

    private func registerTagCollectionViewCellNib() {
        let nib = UINib(nibName: TagCollectionViewCell.nibName, bundle: nibBundle)
        let reuseIdentifier = TagCollectionViewCell.reuseIdentifier
        collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

    private func reloadData() {
        instagramService.authorize { [weak self] token in
            self?.instagramService.searchForTags("hamilton") { [weak self] result in
                guard let `self` = self else { return }
                if let result = result {
                    self.tags = result
                    self.collectionView.reloadData()
                }
            }
        }
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
            log.error("Could not dequeue TagCollectionViewCell")
            return TagCollectionViewCell()
        }

        // Configure the cell
        guard tags.count > indexPath.row else {
            return TagCollectionViewCell()
        }
        let viewModel = TagCollectionCellViewModel(tag: tags[indexPath.row].name, imageURL: nil)
        cell.configure(viewModel)

        return cell
    }

}

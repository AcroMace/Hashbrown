//
//  TagSearchViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-05.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

class TagSearchViewController: UIViewController {

    static let storyboardName = String(TagSearchViewController)
    static let numberOfColumns: CGFloat = 3

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    private let instagramService = InstagramService()
    private var tags = [InstagramTag]()

    class func createInstance() -> TagSearchViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: TagSearchViewController.self))
        let instance = storyboard.instantiateInitialViewController() as! TagSearchViewController
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        registerTagSearchCollectionViewCellNib()

        reloadData()
    }

    private func registerTagSearchCollectionViewCellNib() {
        let nib = UINib(nibName: TagSearchCollectionViewCell.nibName, bundle: nibBundle)
        let reuseIdentifier = TagSearchCollectionViewCell.reuseIdentifier
        collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

    private func reloadData() {
        instagramService.searchForTags("hamilton") { [weak self] result in
            guard let `self` = self else { return }
            guard let `result` = result else { return }
            self.tags = result
            self.collectionView.reloadData()
        }
    }

}

// MARK: TagSearchCollectionViewCellDelegate

extension TagSearchViewController: TagSearchCollectionViewCellDelegate {

    func didTapAddTagButton(tag: String) {
        log.debug("Adding tag: \(tag)")
    }

}

// MARK: UISearchBarDelegate

extension TagSearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("Search button clicked: \(searchBar.text)")
        searchBar.resignFirstResponder()
    }

}

// MARK: UICollectionViewDelegate

extension TagSearchViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = floor(view.frame.width / TagSearchViewController.numberOfColumns)
        return CGSize(width: width, height: width)
    }

    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row < tags.count else {
            log.error("Tapped a cell that was out of range")
            return
        }

        let tag = tags[indexPath.row]
        log.debug("Added \(tag.name) to saved tags")
    }

}

// MARK: UICollectionViewDataSource

extension TagSearchViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TagSearchCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as? TagSearchCollectionViewCell else {
            log.error("Could not dequeue TagSearchCollectionViewCell")
            return TagSearchCollectionViewCell()
        }
        cell.delegate = self

        // Configure the cell
        guard tags.count > indexPath.row else {
            return TagSearchCollectionViewCell()
        }

        let tag = tags[indexPath.row]
        let viewModel = TagSearchCollectionCellViewModel(tagName: tag.name, tagMediaCount: tag.mediaCount, imageURL: nil)
        cell.configure(viewModel)

        return cell
    }

}

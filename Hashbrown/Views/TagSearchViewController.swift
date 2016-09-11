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

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    private let instagramService = InstagramService()
    private var tags = [InstagramTag]()
    private var addedTags = [String: Bool]() // [Tag name: Added]

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
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView.reloadData()
    }

    private func registerTagSearchCollectionViewCellNib() {
        let nib = UINib(nibName: TagSearchCollectionViewCell.nibName, bundle: nibBundle)
        let reuseIdentifier = TagSearchCollectionViewCell.reuseIdentifier
        collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

}

// MARK: UISearchBarDelegate

extension TagSearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        guard let query = searchBar.text else { return }
        search(query)
    }

    private func search(query: String) {
        log.debug("Searching for: \(query)")
        instagramService.searchForTags(query) { [weak self] result in
            guard let `self` = self, `result` = result else { return }
            self.tags = result
            self.collectionView.reloadData()
        }
    }

}

// MARK: UICollectionViewDelegate

extension TagSearchViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = floor(view.frame.width / Constants.Design.numberOfColumns)
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

        let tagName = tags[indexPath.row].name
        if addedTags[tagName] == true {
            addedTags[tagName] = nil
            log.debug("Removed \(tagName) from saved tags")
        } else {
            addedTags[tagName] = true
            log.debug("Added \(tagName) to saved tags")
        }
        collectionView.reloadData()
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

        guard tags.count > indexPath.row else {
            return TagSearchCollectionViewCell()
        }

        // Configure the cell
        let tag = tags[indexPath.row]
        let viewModel = TagSearchCollectionCellViewModel(
            tagName: tag.name,
            tagMediaCount: tag.mediaCount,
            imageURL: nil,
            isAlreadyAdded: addedTags[tag.name] == true,
            row: indexPath.row)
        cell.configure(viewModel)

        return cell
    }

}

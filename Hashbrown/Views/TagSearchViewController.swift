//
//  TagSearchViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-05.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

class TagSearchViewController: UIViewController {

    static let storyboardName = String(describing: TagSearchViewController.self)

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate let instagramService = InstagramService()
    fileprivate var tags = [InstagramTag]()
    fileprivate var addedTags = [String: Bool]() // [Tag name: Added]

    class func createInstance() -> TagSearchViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: TagSearchViewController.self))
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }

    fileprivate func registerTagSearchCollectionViewCellNib() {
        let nib = UINib(nibName: TagSearchCollectionViewCell.nibName, bundle: nibBundle)
        let reuseIdentifier = TagSearchCollectionViewCell.reuseIdentifier
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

}

// MARK: UISearchBarDelegate

extension TagSearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        guard let query = searchBar.text else { return }
        search(query)
    }

    fileprivate func search(_ query: String) {
        log.debug("Searching for: \(query)")
        instagramService.searchForTags(query: query) { [weak self] result in
            guard let `self` = self, let `result` = result else { return }
            self.tags = result
            self.collectionView.reloadData()
        }
    }

}

// MARK: UICollectionViewDelegate

extension TagSearchViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = floor(view.frame.width / Constants.Design.numberOfColumns)
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagSearchCollectionViewCell.reuseIdentifier, for: indexPath) as? TagSearchCollectionViewCell else {
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

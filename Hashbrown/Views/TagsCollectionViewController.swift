//
//  TagsCollectionViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

class TagsCollectionViewController: UIViewController {

    static let storyboardName = String(TagsCollectionViewController)
    static let numberOfColumns: CGFloat = 3

    @IBOutlet weak var collectionView: UICollectionView!

    private let instagramService = InstagramService()
    private var tags = [InstagramTag]()

    class func createInstance() -> TagsCollectionViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: TagsCollectionViewController.self))
        let instance = storyboard.instantiateInitialViewController() as! TagsCollectionViewController
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        popTheNavigationStack()
        addPlusButton()

        collectionView.delegate = self
        collectionView.dataSource = self
        registerTagCollectionViewCellNib()

        reloadData()
    }

    private func registerTagCollectionViewCellNib() {
        let nib = UINib(nibName: TagCollectionViewCell.nibName, bundle: nibBundle)
        let reuseIdentifier = TagCollectionViewCell.reuseIdentifier
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

    private func addPlusButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(openSearchView))
    }

    @objc private func openSearchView() {
        let searchVC = TagSearchViewController.createInstance()
        navigationController?.pushViewController(searchVC, animated: true)
    }

    private func popTheNavigationStack() {
        // Pop the navigation stack so that we no longer have the back button
        guard let thisViewController = navigationController?.viewControllers.last else { return }
        navigationController?.viewControllers = [thisViewController]
        navigationItem.hidesBackButton = true
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

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row < tags.count else {
            log.error("Tapped a cell that was out of range")
            return
        }

        let tag = tags[indexPath.row]
        let postsCollectionVC = PostsCollectionViewController.createInstance(tag.name)
        navigationController?.pushViewController(postsCollectionVC, animated: true)
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

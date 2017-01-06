//
//  TagsCollectionViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

class TagsCollectionViewController: UIViewController {

    static let storyboardName = String(describing: TagsCollectionViewController.self)

    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate let instagramService = InstagramService()
    fileprivate var tags = [InstagramTag]()

    class func createInstance() -> TagsCollectionViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: TagsCollectionViewController.self))
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }

    fileprivate func registerTagCollectionViewCellNib() {
        let nib = UINib(nibName: TagCollectionViewCell.nibName, bundle: nibBundle)
        let reuseIdentifier = TagCollectionViewCell.reuseIdentifier
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

    fileprivate func reloadData() {
        instagramService.searchForTags(query: "hamilton") { [weak self] result in
            guard let `self` = self else { return }
            guard let `result` = result else { return }
            self.tags = result
            self.collectionView.reloadData()
        }
    }

    fileprivate func addPlusButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openSearchView))
    }

    @objc fileprivate func openSearchView() {
        let searchVC = TagSearchViewController.createInstance()
        navigationController?.pushViewController(searchVC, animated: true)
    }

    fileprivate func popTheNavigationStack() {
        // Pop the navigation stack so that we no longer have the back button
        guard let thisViewController = navigationController?.viewControllers.last else { return }
        navigationController?.viewControllers = [thisViewController]
        navigationItem.hidesBackButton = true
    }

}

// MARK: UICollectionViewDelegate

extension TagsCollectionViewController: UICollectionViewDelegate {

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

        let tag = tags[indexPath.row]
        let postsCollectionVC = PostsCollectionViewController.createInstance(tag.name)
        navigationController?.pushViewController(postsCollectionVC, animated: true)
    }

}

// MARK: UICollectionViewDataSource

extension TagsCollectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.reuseIdentifier, for: indexPath) as? TagCollectionViewCell else {
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

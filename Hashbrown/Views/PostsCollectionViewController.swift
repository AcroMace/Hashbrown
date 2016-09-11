//
//  PostsCollectionViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-02.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

struct PostsCollectionViewModel {
    let tag: String
}

class PostsCollectionViewController: UIViewController {

    static let storyboardName = String(PostsCollectionViewController)

    @IBOutlet weak var collectionView: UICollectionView!

    private let instagramService = InstagramService()

    private var viewModel: PostsCollectionViewModel!
    private var posts = [InstagramPost]()

    class func createInstance(tag: String) -> PostsCollectionViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: PostsCollectionViewController.self))
        let instance = storyboard.instantiateInitialViewController() as! PostsCollectionViewController
        instance.viewModel = PostsCollectionViewModel(tag: tag)
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("Loaded PostsCollectionViewController with tag \(viewModel.tag)")

        collectionView.delegate = self
        collectionView.dataSource = self
        registerPostsCollectionViewCellNib()

        reloadData()
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView.reloadData()
    }

    private func registerPostsCollectionViewCellNib() {
        let nib = UINib(nibName: PostsCollectionViewCell.nibName, bundle: nibBundle)
        let reuseIdentifier = PostsCollectionViewCell.reuseIdentifier
        collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

    func reloadData() {
        instagramService.imagesForTag("polymerclay") { [weak self] result in
            guard let `self` = self else { return }
            guard let `result` = result else { return }
            self.posts = result
            self.collectionView.reloadData()
        }
    }

}

// MARK: UICollectionViewDelegate

extension PostsCollectionViewController: UICollectionViewDelegate {

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

}

// MARK: UICollectionViewDataSource

extension PostsCollectionViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PostsCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as? PostsCollectionViewCell else {
            log.error("Could not dequeue PostsCollectionViewCell")
            return PostsCollectionViewCell()
        }

        // Configure the cell
        guard posts.count > indexPath.row else {
            return PostsCollectionViewCell()
        }
        let viewModel = PostsCollectionCellViewModel(post: posts[indexPath.row])
        cell.configure(viewModel)

        return cell
    }

}

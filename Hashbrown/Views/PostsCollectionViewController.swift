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

    static let storyboardName = String(describing: PostsCollectionViewController.self)

    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate let instagramService = InstagramService()

    fileprivate var viewModel: PostsCollectionViewModel!
    fileprivate var posts = [InstagramPost]()

    class func createInstance(_ tag: String) -> PostsCollectionViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: PostsCollectionViewController.self))
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }

    fileprivate func registerPostsCollectionViewCellNib() {
        let nib = UINib(nibName: PostsCollectionViewCell.nibName, bundle: nibBundle)
        let reuseIdentifier = PostsCollectionViewCell.reuseIdentifier
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

    func reloadData() {
        instagramService.images(for: "polymerclay") { [weak self] result in
            guard let `self` = self else { return }
            guard let `result` = result else { return }
            self.posts = result
            self.collectionView.reloadData()
        }
    }

}

// MARK: UICollectionViewDelegate

extension PostsCollectionViewController: UICollectionViewDelegate {

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

}

// MARK: UICollectionViewDataSource

extension PostsCollectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostsCollectionViewCell.reuseIdentifier, for: indexPath) as? PostsCollectionViewCell else {
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

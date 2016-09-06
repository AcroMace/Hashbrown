//
//  AuthorizeViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

class AuthorizeViewController: UIViewController {

    private let instagramService = InstagramService()

    override func viewDidLoad() {
        super.viewDidLoad()

        if instagramService.isAuthorized() {
            showTags(false)
        }
    }

    @IBAction func authorizeWithInstagram(sender: AnyObject) {
        instagramService.authorize { [weak self] authToken in
            self?.showTags(true)
        }
    }

    private func showTags(animated: Bool) {
        let tagsCollectionVC = TagsCollectionViewController.createInstance()
        navigationController?.pushViewController(tagsCollectionVC, animated: animated)
    }

}

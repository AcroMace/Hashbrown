//
//  AuthorizeViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

class AuthorizeViewController: UIViewController {

    fileprivate let instagramService = InstagramService()

    override func viewDidLoad() {
        super.viewDidLoad()

        if instagramService.isAuthorized() {
            showTags(false)
        }
    }

    @IBAction func authorizeWithInstagram(_ sender: AnyObject) {
        instagramService.authorize(container: self, { [weak self] authToken in
            self?.showTags(true)
        })
    }

    fileprivate func showTags(_ animated: Bool) {
        let tagsCollectionVC = TagsCollectionViewController.createInstance()
        navigationController?.pushViewController(tagsCollectionVC, animated: animated)
    }

}

//
//  AuthorizeViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

class AuthorizeViewController: UIViewController {
    let instagramService = InstagramService()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func authorizeWithInstagram(sender: AnyObject) {
        instagramService.authorize { [weak self] authToken in
            let tagsCollectionVC = TagsCollectionViewController.createInstance(authToken)
            self?.navigationController?.pushViewController(tagsCollectionVC, animated: true)
        }
    }

}

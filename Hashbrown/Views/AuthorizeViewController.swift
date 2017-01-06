//
//  AuthorizeViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit
import InstagramKit

class AuthorizeViewController: UIViewController {

    fileprivate let instagramService = InstagramService()
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if instagramService.isAuthorized() {
            showTags(false)
        }
    }

    @IBAction func authorizeWithInstagram(_ sender: AnyObject) {
        instagramService.authorize(webView: webView, delegate: self)
    }

}

// MARK: InstagramServiceAuthorizationDelegate

extension AuthorizeViewController: InstagramServiceAuthorizationDelegate {

    func didAuthorize(authToken: String) {
        showTags(true)
    }

    fileprivate func showTags(_ animated: Bool) {
        let tagsCollectionVC = TagsCollectionViewController.createInstance()
        navigationController?.pushViewController(tagsCollectionVC, animated: animated)
    }

}

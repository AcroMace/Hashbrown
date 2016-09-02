//
//  TagsCollectionViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

struct TagsCollectionViewModel {
    let authToken: String
}

class TagsCollectionViewController: UIViewController {

    static let storyboardName = String(TagsCollectionViewController)

    private var viewModel: TagsCollectionViewModel!

    class func createInstance(authToken: String) -> TagsCollectionViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: TagsCollectionViewController.self))
        let instance = storyboard.instantiateInitialViewController() as! TagsCollectionViewController
        instance.viewModel = TagsCollectionViewModel(authToken: authToken)
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Loaded TagsCollectionViewController with auth token \(viewModel.authToken)")
    }

}

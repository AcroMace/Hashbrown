//
//  ViewController.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-08-31.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let instagramService = InstagramService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func authorizeInstagram(sender: AnyObject) {
        instagramService.authorize { token in
            print("Instagram token fetched: \(token)")
        }
    }

}

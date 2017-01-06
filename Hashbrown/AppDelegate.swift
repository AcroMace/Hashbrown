//
//  AppDelegate.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-08-31.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupSwiftyBeaver()
        return true
    }

    fileprivate func setupSwiftyBeaver() {
        let console = ConsoleDestination()
        log.addDestination(console)
    }

}

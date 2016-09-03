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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupSwiftyBeaver()
        return true
    }

    private func setupSwiftyBeaver() {
        let console = ConsoleDestination()
        log.addDestination(console)
    }

}

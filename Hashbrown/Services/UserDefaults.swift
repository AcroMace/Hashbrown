//
//  UserDefaults.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

struct UserDefaults {

    static func get(key: String) -> AnyObject? {
        return getInstance().objectForKey(key)
    }

    static func save(key: String, value: AnyObject) {
        getInstance().setObject(value, forKey: key)
    }

    static func delete(key: String) {
        getInstance().setObject(nil, forKey: key)
    }

    static private func getInstance() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }

}

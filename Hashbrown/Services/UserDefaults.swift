//
//  UserDefaults.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

struct UserDefaults {

    static func get(key: String) -> Any? {
        return getInstance().object(forKey: key) as Any?
    }

    static func save(key: String, value: Any) {
        getInstance().set(value, forKey: key)
    }

    static func delete(
        key: String) {
        getInstance().set(nil, forKey: key)
    }

    static fileprivate func getInstance() -> Foundation.UserDefaults {
        return Foundation.UserDefaults.standard
    }

}

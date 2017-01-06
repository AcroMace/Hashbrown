//
//  Constants.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

struct Constants {

    struct Instagram {
        static let clientID = "a11d750426144ae6a8bb25c79afae138"
        static let oauthScope = [
            // User profile
            "basic",
            // Ability to search for tags, get public images
            "public_content",
            // Ability to like photos
            "likes"
        ]
    }

    struct UserDefaults {
        static let instagramAuthToken = "instagramAuthToken"
    }

    struct Design {
        static let numberOfColumns: CGFloat = 3
    }

}

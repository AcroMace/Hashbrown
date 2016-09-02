//
//  Constants.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

struct Constants {

    struct Instagram {
        static let simpleAuthCategory = "instagram"
        static let clientID = "a11d750426144ae6a8bb25c79afae138"
        static let redirectURI = "https://acromace.com"
        static let oauthScope = [
            // User profile
            "basic",
            // Ability to search for tags, get public images
            "public_content",
            // Ability to like photos
            "likes"
        ]
    }

}

//
//  InstagramUser.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-02.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import SwiftyJSON

struct InstagramUser {

    let username: String
    let userID: String
    let profilePicture: String
    let fullName: String

    /**
     Parse an Instagram user from JSON

     - parameter json: JSON returned from a tag search

     - returns: A parsed Instagram user, `nil` if the parsing failed
     */
    static func parseFromJSON(json: JSON) -> InstagramUser? {
        guard let username = json["username"].string,
            id = json["id"].string,
            profilePicture = json["profile_picture"].string,
            fullName = json["full_name"].string else {
                log.warning("Could not parse user from JSON: \(json)")
                return nil
        }
        return InstagramUser(
            username: username,
            userID: id,
            profilePicture: profilePicture,
            fullName: fullName)
    }

}

//
//  InstagramService.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import SimpleAuth
import SwiftyJSON

class InstagramService {
    /// Auth token returned by Instagram
    private var authToken: String? = nil

    init() {
        // Initialize SimpleAuth for Instagram authorization
        SimpleAuth.configuration()[Constants.Instagram.simpleAuthProvider] = [
            "client_id": Constants.Instagram.clientID,
            SimpleAuthRedirectURIKey: Constants.Instagram.redirectURI
        ]
    }

    /**
     Authorize with Instagram and return the authorization token

     - parameter callback: Calls back with the Instagram auth token
     */
    func authorize(callback: (String -> Void)) {
        // If we already fetched the token, just return it
        if let authToken = authToken {
            callback(authToken)
            return
        }

        let provider = Constants.Instagram.simpleAuthProvider
        let options = ["scope": Constants.Instagram.oauthScope]
        SimpleAuth.authorize(provider, options: options) { [weak self] response, error in
            guard let `self` = self else { return }
            guard let authToken = JSON(response)["credentials"]["token"].string else {
                print("ERROR: Could not fetch auth token from Instagram")
                return
            }

            // Cache the token so that we don't need to authorize again later
            self.authToken = authToken
            callback(authToken)
        }
    }

}

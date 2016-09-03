//
//  InstagramService.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import Alamofire
import Haneke
import SimpleAuth
import SwiftyJSON

private enum InstagramURL {

    case TagSearch
    case ImagesForTag(tag: String)

    func path() -> String {
        switch self {
        case .TagSearch:
            return "v1/tags/search"
        case .ImagesForTag(let tag):
            return "v1/tags/\(tag)/media/recent"
        }
    }

}

class InstagramService {

    private static let baseURL = "https://api.instagram.com/"

    /// Reference to the cache
    private let cache = Shared.dataCache

    /// Auth token returned by Instagram
    private static var authToken: String? = nil

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
        if let authToken = InstagramService.authToken {
            callback(authToken)
            return
        }

        // See if it's saved in user defaults
        if let authToken = UserDefaults.get(Constants.UserDefaults.instagramAuthToken) as? String {
            InstagramService.authToken = authToken
            callback(authToken)
            return
        }

        let provider = Constants.Instagram.simpleAuthProvider
        let options = ["scope": Constants.Instagram.oauthScope]
        SimpleAuth.authorize(provider, options: options) { [weak self] response, error in
            guard let `self` = self else { return }
            guard let authToken = JSON(response)["credentials"]["token"].string else {
                log.error("Could not fetch auth token from Instagram")
                return
            }

            // Cache the token so that we don't need to authorize again later
            InstagramService.authToken = authToken
            UserDefaults.save(Constants.UserDefaults.instagramAuthToken, value: authToken)
            callback(authToken)
        }
    }

    /**
     Search for tags given a query

     - parameter query:    The query given to search for tags
     - parameter callback: Callback with a list of tags
     */
    func searchForTags(query: String, callback: ([InstagramTag]? -> Void)) {
        guard let authToken = InstagramService.authToken else {
            log.error("Attempted to search Instagram without being authorized")
            return
        }

        let parameters = ["q": query, "access_token": authToken]
        guard let url = constructURL(.TagSearch, parameters: parameters) else {
            log.error("Could not construct searchForTags URL")
            return
        }

        cache.fetch(key: url)
            .onSuccess({ data in
                log.debug("Cache hit for \(url)")
                guard let tags = InstagramTag.parseFromJSON(JSON(data: data)) else {
                    log.error("Unexpected format returned from cache \(url)")
                    return
                }
                callback(tags)
            })
            .onFailure({ [weak self] _ in
                log.debug("Cache miss for \(url)")
                self?.searchForTagsNetwork(url, callback: callback)
            })
    }

    func imagesForTag(tag: String, callback: ([InstagramPost]? -> Void)) {
        guard let authToken = InstagramService.authToken else {
            log.error("Attempted to search Instagram without being authorized")
            return
        }

        let parameters = ["access_token": authToken]
        guard let url = constructURL(.ImagesForTag(tag: tag), parameters: parameters) else {
            log.error("Could not construct getImagesForTag URL")
            return
        }

        cache.fetch(key: url)
            .onSuccess({ data in
                log.debug("Cache hit for \(url)")
                guard let posts = InstagramPost.parseFromJSON(JSON(data: data)) else {
                    log.error("Unexpected format returned from cache \(url)")
                    return
                }
                callback(posts)
            })
            .onFailure({ [weak self] _ in
                log.debug("Cache miss for \(url)")
                self?.imagesForTagNetwork(url, callback: callback)
            })
    }

    /**
     Construct a URL string from the URL type
     Used instead of specifying the parameters in Alamofire to allow using the URL
     as a key for the cache

     - parameter url:        Type of the URL being constructed
     - parameter parameters: Query parameters for the URL

     - returns: The URL to query
     */
    private func constructURL(url: InstagramURL, parameters: [String: String]) -> String? {
        let urlComponents = NSURLComponents(string: InstagramService.baseURL + url.path())
        let queryItems = parameters.map { NSURLQueryItem(name: $0, value: $1) }
        urlComponents?.queryItems = queryItems
        return urlComponents?.URL?.absoluteString
    }

}

// MARK: Network calls

extension InstagramService {

    /**
     Search for Instagram tags from the network
     Saves the result to cache if successful

     - parameter url:      URL string constructed from `constructURL`
     - parameter callback: Callback with a list of tags
     */
    private func searchForTagsNetwork(url: String, callback: ([InstagramTag]? -> Void)) {
        Alamofire.request(.GET, url)
            .validate()
            .responseJSON { [weak self] response in
                guard let `self` = self else { return }
                switch response.result {
                case .Success:
                    guard let value = response.result.value else {
                        log.error("Server returned nil while searching for tags \(url)")
                        return
                    }
                    dispatch_background {
                        // Parse the JSON in the background
                        let json = JSON(value)
                        let tags = InstagramTag.parseFromJSON(json)

                        dispatch_main_async {
                            self.cacheJSON(url, json: json)
                            callback(tags)
                        }
                    }
                case .Failure(let error):
                    log.error(error)
                }
        }
    }

    private func imagesForTagNetwork(url: String, callback: ([InstagramPost]? -> Void)) {
        Alamofire.request(.GET, url)
            .validate()
            .responseJSON { [weak self] response in
                guard let `self` = self else { return }
                switch response.result {
                case .Success:
                    guard let value = response.result.value else {
                        log.error("Server returned nil while getting images for tag \(url)")
                        return
                    }
                    dispatch_background {
                        // Parse the JSON in the background
                        let json = JSON(value)
                        let posts = InstagramPost.parseFromJSON(json)

                        dispatch_main_async {
                            self.cacheJSON(url, json: json)
                            callback(posts)
                        }
                    }
                case .Failure(let error):
                    log.error(error)
                }
        }
    }

    /**
     Cache a JSON instance

     - parameter key:  The string key (ex. URL)
     - parameter json: The JSON object to save
     */
    private func cacheJSON(key: String, json: SwiftyJSON.JSON) {
        guard let data = try? json.rawData() else {
            log.error("Failed to cache JSON for key \(key)")
            return
        }
        cache.set(value: data, key: key) { result in
            log.debug("Successfully cached JSON for \(key)")
        }
    }

}

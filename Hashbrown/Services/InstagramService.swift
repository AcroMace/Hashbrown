//
//  InstagramService.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import Alamofire
import Haneke
import SwiftyJSON

private enum InstagramURL {

    case tagSearch
    case imagesForTag(tag: String)

    func path() -> String {
        switch self {
        case .tagSearch:
            return "v1/tags/search"
        case .imagesForTag(let tag):
            return "v1/tags/\(tag)/media/recent"
        }
    }

}

class InstagramService {

    fileprivate static let baseURL = "https://api.instagram.com/"

    /// Reference to the cache
    fileprivate let cache = Shared.dataCache

    /// Auth token returned by Instagram
    fileprivate static var authToken: String? = nil

    /**
     Check if the user is already authorized

     - returns: True if the user is authorized, false if not
     */
    func isAuthorized() -> Bool {
        return getCachedAuthToken() != nil
    }

    /**
     Authorize with Instagram and return the authorization token

     - parameter callback: Calls back with the Instagram auth token
     */
    func authorize(container: UIViewController, _ callback: @escaping ((String) -> Void)) {
        // See if we already have the token cached (pre-fetched or in user defaults)
        if let authToken = getCachedAuthToken() {
            callback(authToken)
            return
        }

        // TODO: Add OAuth code here
    }

    /**
     Search for tags given a query

     - parameter query:    The query given to search for tags
     - parameter callback: Callback with a list of tags
     */
    func searchForTags(query: String, callback: @escaping (([InstagramTag]?) -> Void)) {
        guard let authToken = InstagramService.authToken else {
            log.error("Attempted to search Instagram without being authorized")
            return
        }

        let parameters = ["q": query.lowercased(), "access_token": authToken]
        guard let url = constructURL(with: .tagSearch, parameters: parameters) else {
            log.error("Could not construct searchForTags URL")
            return
        }

        cache.fetch(key: url)
            .onSuccess({ data in
                log.debug("Cache hit for \(url)")
                guard let tags = InstagramTag.parse(from: JSON(data: data)) else {
                    log.error("Unexpected format returned from cache \(url)")
                    return
                }
                callback(tags)
            })
            .onFailure({ [weak self] _ in
                log.debug("Cache miss for \(url)")
                self?.searchForTagsNetwork(with: url, callback: callback)
            })
    }

    func images(for tag: String, callback: @escaping (([InstagramPost]?) -> Void)) {
        guard let authToken = InstagramService.authToken else {
            log.error("Attempted to search Instagram without being authorized")
            return
        }

        let parameters = ["access_token": authToken]
        guard let url = constructURL(with: .imagesForTag(tag: tag), parameters: parameters) else {
            log.error("Could not construct getImagesForTag URL")
            return
        }

        cache.fetch(key: url)
            .onSuccess({ data in
                log.debug("Cache hit for \(url)")
                guard let posts = InstagramPost.parse(from: JSON(data: data)) else {
                    log.error("Unexpected format returned from cache \(url)")
                    return
                }
                callback(posts)
            })
            .onFailure({ [weak self] _ in
                log.debug("Cache miss for \(url)")
                self?.imagesForTagNetwork(with: url, callback: callback)
            })
    }

    // MARK: Private methods

    /**
     Check if the auth token is cached

     - returns: Return the auth token if it exists, nil if not
     */
    fileprivate func getCachedAuthToken() -> String? {
        // If we already fetched the token, just return it
        if let authToken = InstagramService.authToken {
            return authToken
        }

        // See if it's saved in user defaults
        if let authToken = UserDefaults.get(key: Constants.UserDefaults.instagramAuthToken) as? String {
            InstagramService.authToken = authToken
            return authToken
        }

        return nil
    }

    /**
     Construct a URL string from the URL type
     Used instead of specifying the parameters in Alamofire to allow using the URL
     as a key for the cache

     - parameter url:        Type of the URL being constructed
     - parameter parameters: Query parameters for the URL

     - returns: The URL to query
     */
    fileprivate func constructURL(with url: InstagramURL, parameters: [String: String]) -> String? {
        var urlComponents = URLComponents(string: InstagramService.baseURL + url.path())
        let queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        urlComponents?.queryItems = queryItems
        return urlComponents?.url?.absoluteString
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
    fileprivate func searchForTagsNetwork(with url: String, callback: @escaping (([InstagramTag]?) -> Void)) {
        Alamofire.request(url)
            .validate()
            .responseJSON { [weak self] response in
                guard let `self` = self else { return }
                switch response.result {
                case .success:
                    guard let value = response.result.value else {
                        log.error("Server returned nil while searching for tags \(url)")
                        return
                    }
                    dispatch_background {
                        // Parse the JSON in the background
                        let json = JSON(value)
                        let tags = InstagramTag.parse(from: json)

                        dispatch_main_async {
                            self.cacheJSON(key: url, json: json)
                            callback(tags)
                        }
                    }
                case .failure(let error):
                    log.error(error)
                }
        }
    }

    fileprivate func imagesForTagNetwork(with url: String, callback: @escaping (([InstagramPost]?) -> Void)) {
        Alamofire.request(url)
            .validate()
            .responseJSON { [weak self] response in
                guard let `self` = self else { return }
                switch response.result {
                case .success:
                    guard let value = response.result.value else {
                        log.error("Server returned nil while getting images for tag \(url)")
                        return
                    }
                    dispatch_background {
                        // Parse the JSON in the background
                        let json = JSON(value)
                        let posts = InstagramPost.parse(from: json)

                        dispatch_main_async {
                            self.cacheJSON(key: url, json: json)
                            callback(posts)
                        }
                    }
                case .failure(let error):
                    log.error(error)
                }
        }
    }

    /**
     Cache a JSON instance

     - parameter key:  The string key (ex. URL)
     - parameter json: The JSON object to save
     */
    fileprivate func cacheJSON(key: String, json: SwiftyJSON.JSON) {
        guard let data = try? json.rawData() else {
            log.error("Failed to cache JSON for key \(key)")
            return
        }
        cache.set(value: data, key: key) { result in
            log.debug("Successfully cached JSON for \(key)")
        }
    }

}

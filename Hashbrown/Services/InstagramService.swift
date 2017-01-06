//
//  InstagramService.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-01.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import Alamofire
import Haneke
import InstagramKit
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

/// A protocol for a delegate that is notified when the user is authorized with Instagram
protocol InstagramServiceAuthorizationDelegate {

    // This is kind of weird, but we need to listen for the UIWebView to see when it redirects
    // with the auth token
    // The alternative is saving the callback method as a property and then calling it
    // after we get the event from the UIWebView

    /// Called after the user is authorized with Instagram
    func didAuthorize(authToken: String)

}

class InstagramService: NSObject {

    fileprivate static let baseURL = "https://api.instagram.com/"

    /// Reference to the cache
    fileprivate let cache = Shared.dataCache

    /// Auth token returned by Instagram
    fileprivate static var authToken: String? = nil

    /// The delegate to notify after authorization (see func authorize)
    fileprivate var authorizationDelegate: InstagramServiceAuthorizationDelegate?

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
    func authorize(webView: UIWebView, delegate: InstagramServiceAuthorizationDelegate) {
        self.authorizationDelegate = delegate

        // See if we already have the token cached (pre-fetched or in user defaults)
        if let authToken = getCachedAuthToken() {
            delegate.didAuthorize(authToken: authToken)
            return
        }

        // Get the redirect requests
        webView.delegate = self

        // Start loading the requests in the provided UIWebView
        let authURL = InstagramEngine.shared().authorizationURL()
        webView.loadRequest(URLRequest(url: authURL))
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

// MARK: UIWebViewDelegate

extension InstagramService: UIWebViewDelegate {

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // Just navigate to the URL if the user wasn't authenticated
        guard let url = request.url, String(describing: url).range(of: "access") != nil else {
            return true
        }

        // Check that the token is valid
        let engine = InstagramEngine.shared()
        guard let _ = try? engine.receivedValidAccessToken(from: url) else {
            return true
        }

        if let accessToken = engine.accessToken {
            // Cache the token so that we don't need to authorize again later
            InstagramService.authToken = accessToken
            UserDefaults.save(key: Constants.UserDefaults.instagramAuthToken, value: accessToken)

            // Tell the delegate that the authorization is complete
            authorizationDelegate?.didAuthorize(authToken: accessToken)
        }
        return true
    }

}

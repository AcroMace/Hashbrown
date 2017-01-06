//
//  InstagramPost.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-02.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import SwiftyJSON

struct InstagramPost {

    let postID: String
    let createdTime: NSDate
    let caption: String
    let link: String
    let tags: [String]
    let likes: Int
    let type: String
    let filter: String
    let imageURL: String
    let userHasLiked: Bool
    let user: InstagramUser
    let location: InstagramLocation?

    /**
     Parse a list of InstagramPost from a tag search

     - parameter json: JSON returned from a tag search

     - returns: A parsed list of tags, `nil` if the parsing failed
     */
    static func parse(from json: JSON) -> [InstagramPost]? {
        guard let postList = json["data"].array else {
            log.error("Could not parse list of posts from JSON \(json)")
            return nil
        }

        // Used for pagination
        let minTagID = json["pagination"]["min_tag_id"].string
        log.info("minTagID: \(minTagID)")

        return postList.flatMap { parsePost(from: $0) }
    }

    /**
     Parse an Instagram post from JSON

     - parameter json: JSON returned from a tag search

     - returns: A parsed Instagram user, `nil` if the parsing failed
     */
    static func parsePost(from json: JSON) -> InstagramPost? {
        guard let id = json["id"].string,
            let createdTime = json["created_time"].string,
            let createdTimeInt = Int(createdTime),
            let caption = json["caption"]["text"].string,
            let link = json["link"].string,
            let tags = json["tags"].array?.flatMap({ $0.string }),
            let likes = json["likes"]["count"].int,
            let type = json["type"].string,
            let filter = json["filter"].string,
            let imageURL = json["images"]["standard_resolution"]["url"].string,
            let userHasLiked = json["user_has_liked"].bool,
            let user = InstagramUser.parse(from: json["user"]) else {
                log.warning("Could not parse post from JSON: \(json)")
                return nil
        }

        let location = InstagramLocation.parse(from: json["location"])
        let createdTimeDate = NSDate(timeIntervalSince1970: TimeInterval(createdTimeInt))

        return InstagramPost(
            postID: id,
            createdTime: createdTimeDate,
            caption: caption,
            link: link,
            tags: tags,
            likes: likes,
            type: type,
            filter: filter,
            imageURL: imageURL,
            userHasLiked: userHasLiked,
            user: user,
            location: location)
    }

}

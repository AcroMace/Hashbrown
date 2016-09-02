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
    static func parseFromJSON(json: JSON) -> [InstagramPost]? {
        guard let postList = json["data"].array else {
            log.error("Could not parse list of posts from JSON \(json)")
            return nil
        }

        // Used for pagination
        let minTagID = json["pagination"]["min_tag_id"].string
        log.info("minTagID: \(minTagID)")

        return postList.flatMap { parsePostFromJSON($0) }
    }

    /**
     Parse an Instagram post from JSON

     - parameter json: JSON returned from a tag search

     - returns: A parsed Instagram user, `nil` if the parsing failed
     */
    static func parsePostFromJSON(json: JSON) -> InstagramPost? {
        guard let id = json["id"].string,
            createdTime = json["created_time"].string,
            createdTimeInt = Int(createdTime),
            caption = json["caption"]["text"].string,
            link = json["link"].string,
            tags = json["tags"].array?.flatMap({ $0.string }),
            likes = json["likes"]["count"].int,
            type = json["type"].string,
            filter = json["filter"].string,
            imageURL = json["images"]["standard_resolution"]["url"].string,
            userHasLiked = json["user_has_liked"].bool,
            user = InstagramUser.parseFromJSON(json["user"]) else {
                log.warning("Could not parse post from JSON: \(json)")
                return nil
        }

        let location = InstagramLocation.parseFromJSON(json["location"])
        let createdTimeDate = NSDate(timeIntervalSince1970: NSTimeInterval(createdTimeInt))

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

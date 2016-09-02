//
//  InstagramTag.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-02.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import SwiftyJSON

struct InstagramTag {
    let name: String
    let mediaCount: Int

    /**
     Parse a list of InstagramTags from a tag search

     - parameter json: JSON returned from a tag search

     - returns: A parsed list of tags
     */
    static func parseFromJSON(json: JSON) -> [InstagramTag]? {
        guard let tagList = json["data"].array else {
            log.error("Could not parse list of tags from JSON \(json)")
            return nil
        }

        return tagList.flatMap { tagJSON in
            guard let name = tagJSON["name"].string, mediaCount = tagJSON["media_count"].int else {
                return nil
            }
            return InstagramTag(name: name, mediaCount: mediaCount)
        }
    }
}

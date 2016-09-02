//
//  InstagramLocation.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-02.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import SwiftyJSON

struct InstagramLocation {
    let locationID: String
    let name: String
    let latitude: Double
    let longitude: Double

    /**
     Parse a location from Instagram

     - parameter json: JSON object for a location

     - returns: A parsed location, `nil` if the parsing failed
     */
    static func parseFromJSON(json: JSON) -> InstagramLocation? {
        // Location is nullable
        guard !json.isEmpty else { return nil }

        guard let id = json["id"].int, // Why is this not a string?!
            name = json["name"].string,
            latitude = json["latitude"].double,
            longitude = json["longitude"].double else {
                log.error("Could not parse location from JSON \(json)")
                return nil
        }

        return InstagramLocation(locationID: String(id), name: name, latitude: latitude, longitude: longitude)
    }
}

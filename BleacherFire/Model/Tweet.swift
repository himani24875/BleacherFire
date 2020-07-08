//
//  Tweet.swift
//  BleacherFire
//
//  Created by Himani on 06/07/20.
//  Copyright © 2020 Himani. All rights reserved.
//

import Foundation

struct Tweet : Codable {
    let createdAt : String?
    let text : String?
    let user : User?
    let extendedEntities : ExtendedEntities?

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case text = "text"
        case user = "user"
        case extendedEntities = "extended_entities"
    }
}

struct ExtendedEntities : Codable {
    let media : [Media]?
}

struct Media : Codable {
    let type : String?
    let videoInfo : VideoInfo?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case videoInfo = "video_info"
    }
}

struct VideoInfo : Codable {
    let variants : [Variants]?
}

struct Variants : Codable {
    let url : String?
}

struct User : Codable {
    let profileImageUrl : String?
    let screenName : String?
    let name : String?
    let verified : Bool?

    enum CodingKeys: String, CodingKey {
        case profileImageUrl = "profile_image_url"
        case screenName = "screen_name"
        case name = "name"
        case verified = "verified"
    }
}

struct CellData: Codable {
    var isYoutubeLink = true
    var data: Tweet?
    var urlString = ""
    var videoData: Video?

//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        isYoutubeLink = try values.decodeIfPresent(Bool.self, forKey: .isYoutubeLink)
//        urlString = try values.decodeIfPresent(String.self, forKey: .urlString)
//        data = try values.decodeIfPresent(Tweet.self, forKey: .data)
//    }
    init() {
        //
    }
}

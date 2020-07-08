//
//  Video.swift
//  BleacherFire
//
//  Created by Himani on 07/07/20.
//  Copyright © 2020 Himani. All rights reserved.
//

import Foundation

struct Video : Codable {
    let items : [Items]?

    enum CodingKeys: String, CodingKey {

        case items = "items"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decodeIfPresent([Items].self, forKey: .items)
    }

}

struct Snippet : Codable {
    let publishedAt : String?
    let channelId : String?
    let title : String?
    let description : String?
    let channelTitle : String?

    enum CodingKeys: String, CodingKey {

        case publishedAt = "publishedAt"
        case channelId = "channelId"
        case title = "title"
        case description = "description"
        case channelTitle = "channelTitle"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        publishedAt = try values.decodeIfPresent(String.self, forKey: .publishedAt)
        channelId = try values.decodeIfPresent(String.self, forKey: .channelId)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        channelTitle = try values.decodeIfPresent(String.self, forKey: .channelTitle)
    }

}

struct Items : Codable {
    let kind : String?
    let id : String?
    let snippet : Snippet?

    enum CodingKeys: String, CodingKey {

        case kind = "kind"
        case id = "id"
        case snippet = "snippet"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        kind = try values.decodeIfPresent(String.self, forKey: .kind)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        snippet = try values.decodeIfPresent(Snippet.self, forKey: .snippet)
    }

}



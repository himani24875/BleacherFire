//
//  Constants.swift
//  BleacherFire
//
//  Created by Himani on 08/07/20.
//  Copyright © 2020 Himani. All rights reserved.
//

import Foundation

struct Constants {
    static let TWITTER_CONSUMER_KEY = "f07EfUpb9KRZhkcSgbzQE3uhK"
    static let TW_CONSUMER_SECRET = "ckdp43jVAAorduXGmqFLOEkOrBYPjZpZlvPnOuXIitTJ5kyWQR"
    
    static let YOUTUBE_API_KEY = "AIzaSyBtFnErm35_jrAH9JcC5PWlT3zqDDJBh-c"
    
    static let YT_DATE_TIME_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    static let TW_DATE_TIME_FORMAT = "EEE MMM dd HH:mm:ss zzz yyyy"
    
    static let YT_BASE_URL = "https://www.googleapis.com/youtube/v3/videos?part=snippet&key="+Constants.YOUTUBE_API_KEY+"&id="
    static let TW_BASE_URL = "https://api.twitter.com/1.1/statuses/show.json?id="
    
    struct IDENTIFIERS {
        static let LIST_ITEM_TVC = "ListItemTVC"
        static let WEB_VIEW_VC = "WebViewVC"
    }
}

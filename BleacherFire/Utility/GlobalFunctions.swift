//
//  GlobalFunctions.swift
//  BleacherFire
//
//  Created by Himani on 02/07/20.
//  Copyright © 2020 Himani. All rights reserved.
//

import Foundation
import UIKit

struct GlobalFunctions {
    static let sharedManager = GlobalFunctions()
    
    private init() {
    }
    
    func getURL(_ urlString:String) -> URLRequest {
        
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.scheme = "https"
        
        guard let url = urlComponents?.url else {
            preconditionFailure("Failed to construct URL")
        }
        
        return URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 100)
    }
    
    func getImageFromURL(url: URL, success: @escaping (UIImage) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage.init(data: data) {
                success(image)
            }
        }.resume()
    }
    
    func getDate(from string: String?, dateFormat: String?) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        return dateFormatter.date(from: (string ?? ""))
    }
    
    func timeAgoSinceDate(date: NSDate, numericDates: Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!)y"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1y"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!)m"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1m"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!)w"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1w"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!)d"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1d"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!)h"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1h"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!)min"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1min"
            } else {
                return "min"
            }
        } else {
            return "s"
        }
    }
}


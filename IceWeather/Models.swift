//
//  Models.swift
//  IceWeather
//
//  Created by Kyusaku Mihara on 6/8/15.
//  Copyright (c) 2015 epohsoft. All rights reserved.
//

import Foundation

class IceImage {
    var URL: String!
    var createdAt: String!

    init?(dictionary: [String: AnyObject]) {
        if let imageDictionary = dictionary["image"] as? [String: AnyObject] {
            if let URL = imageDictionary["url"] as? String {
                self.URL = URL
                if let createdAt = imageDictionary["created_at"] as? String {
                    self.createdAt = createdAt
                } else if let createdAtDictionary = imageDictionary["created_at"] as? [String: AnyObject] {
                    if let createdAt = createdAtDictionary["date"] as? String {
                        self.createdAt = createdAt.stringByReplacingOccurrencesOfString(".000000", withString: "")
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

//
//  MovieInfo.swift
//  minichannel
//
//  Created by 長坂翔吾 on 2018/01/14.
//  Copyright © 2018 jp.ne.donuts. All rights reserved.
//

import Foundation
import ObjectMapper

class MovieInfo: Mappable {
    var uid: String?
    var userName: String?
    var moviePath: String?
    var thumbnailPath: String?
    
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    public required init?(map: Map) {
        uid <- map["uid"]
        userName <- map["user_name"]
        moviePath <- map["movie_path"]
        thumbnailPath <- map["thumbnail_path"]
    }
    
    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    public func mapping(map: Map) {
    }
}

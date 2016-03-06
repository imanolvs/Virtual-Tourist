//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Imanol Viana Sánchez on 3/3/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation


struct FlickrConstants {
    
    // MARK: Flickr
    struct Flickr {
        static let MethodUrl = "https://api.flickr.com/services/rest"
        static let APIKey = "1d745443e5e945ad51eb1f72912f4c06"
        
        static let SearchBBoxHalfWidth = 0.05
        static let SearchBBoxHalfHeight = 0.05
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParametersKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParametersValues {
        static let SearchMethod = "flickr.photos.search"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" // 1 means yes
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}

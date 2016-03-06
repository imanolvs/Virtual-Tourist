//
//  ViewControllerExtension.swift
//  Virtual Tourist
//
//  Created by Imanol Viana Sánchez on 4/3/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func bboxString(pin: Pin) -> String
    {
        let lat = pin.latitude as Double
        let long = pin.longitude as Double
        
        let maxLat = min(lat + FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.1)
        let minLat = max(lat - FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.0)
        let maxLon = min(long + FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLonRange.1)
        let minLon = max(long - FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLonRange.0)
        let coordinatesString: String = String(minLon) + "," + String(minLat) + "," + String(maxLon) + "," + String(maxLat)
        
        return coordinatesString
    }

    func getMethodParameters(pin: Pin) -> [String:String] {
        let parameters: [String: String] = [
            FlickrConstants.FlickrParametersKeys.Method : FlickrConstants.FlickrParametersValues.SearchMethod,
            FlickrConstants.FlickrParametersKeys.APIKey : FlickrConstants.Flickr.APIKey,
            FlickrConstants.FlickrParametersKeys.BoundingBox : bboxString(pin),
            FlickrConstants.FlickrParametersKeys.Format : FlickrConstants.FlickrParametersValues.ResponseFormat,
            FlickrConstants.FlickrParametersKeys.NoJSONCallback : FlickrConstants.FlickrParametersValues.DisableJSONCallback,
            FlickrConstants.FlickrParametersKeys.SafeSearch : FlickrConstants.FlickrParametersValues.UseSafeSearch,
            FlickrConstants.FlickrParametersKeys.Extras : FlickrConstants.FlickrParametersValues.MediumURL
        ]

        return parameters
    }
    
}
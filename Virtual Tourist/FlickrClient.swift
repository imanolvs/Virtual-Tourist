//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Imanol Viana Sánchez on 3/3/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit

class FlickrClient: NSObject {
    
    var session: NSURLSession
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var instance = FlickrClient()
        }
        
        return Singleton.instance
    }
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    private func taskForGETPhotos(parameters: [String:AnyObject], completionHandler: (result: [String:AnyObject]?, error: String?) -> Void) -> NSURLSessionDataTask {
        
        let components = NSURLComponents(string: FlickrConstants.Flickr.MethodUrl)!
        components.queryItems = [NSURLQueryItem]()
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        let request = NSURLRequest(URL: (components.URL)!)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                completionHandler(result: nil, error: error)
            }
            
            /* GUARD: Was there an error? */
            guard error == nil else {
                sendError("There was an error with the request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandler: (result: [String:AnyObject]?, error: String?) -> Void) {
        
        var parsedResults: [String:AnyObject]!
        
        do {
            parsedResults = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String:AnyObject]
        } catch {
            completionHandler(result: nil, error: "Could not parse the data as JSON: '\(data)'")
        }
        
        guard let results = parsedResults else {
            completionHandler(result: nil, error: "Could not parse the data as JSON: '\(data)'")
            return
        }
        
        completionHandler(result: results, error: nil)
    }
}


extension FlickrClient {
    
    // Unused function. Just implemented for some improves in future
    private func getRandomPage(parameters: [String:AnyObject], completionHandler: (randPage: Int?, error: String?) -> Void) -> NSURLSessionDataTask {
        
        let task = taskForGETPhotos(parameters) { (result, error) in
            guard error == nil else {
                completionHandler(randPage: nil, error: error)
                return
            }
            
            guard let photosDictionary = result![FlickrConstants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandler(randPage: nil, error: "Cannot find keys '\(FlickrConstants.FlickrResponseKeys.Photos)' in \(result)")
                return
            }
            
            guard let totalPages = photosDictionary[FlickrConstants.FlickrResponseKeys.Pages] as? Int else {
                completionHandler(randPage: nil, error: "Cannot find key \(FlickrConstants.FlickrResponseKeys.Pages) in \(photosDictionary)")
                return
            }
            
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            completionHandler(randPage: randomPage, error: nil)
        }
        
        return task
    }
    
    func downloadPhotos(var parameters: [String:AnyObject], completionHandler: (photoArray: [[String:AnyObject]]?, error: String?) -> Void) -> NSURLSessionDataTask {
        
        let page = Int(arc4random_uniform(UInt32(20))) + 1
        parameters[FlickrConstants.FlickrParametersKeys.Page] = "\(page)"
        parameters[FlickrConstants.FlickrParametersKeys.PerPage] = "18"
        print(parameters)
        let task = taskForGETPhotos(parameters) { (result, error) in
            
            guard error == nil else {
                completionHandler(photoArray: nil, error: error)
                return
            }
            
            guard let photosDictionary = result![FlickrConstants.FlickrResponseKeys.Photos] as? NSDictionary, photoArray = photosDictionary[FlickrConstants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                completionHandler(photoArray: nil, error: "Cannot find keys 'photos' and 'photo' in \(result)")
                return
            }
            
            if photoArray.count == 0 {
                completionHandler(photoArray: nil, error: "Photos Not Found. Try again!")
                return
            }
            
            completionHandler(photoArray: photoArray, error: nil)
        }
        
        return task
    }
    
    func downloadDataImage(photoURL: String, completionHandler: (imageData: NSData?, error: String?) -> Void) -> NSURLSessionTask {
        
        let url = NSURL(string: photoURL)
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                completionHandler(imageData: nil, error: "There was an error with the request: \(error)")
                return
            }
            
            completionHandler(imageData: data, error: nil)
        }
        
        task.resume()
        
        return task
    }
}


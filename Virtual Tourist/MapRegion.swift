//
//  MapRegion.swift
//  Virtual Tourist
//
//  Created by Imanol Viana Sánchez on 6/3/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapRegion : NSManagedObject {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let LatDelta = "latDelta"
        static let LongDelta = "longDelta"
    }
    
    @NSManaged var centerLatitude : NSNumber
    @NSManaged var centerLongitude : NSNumber
    @NSManaged var latitudeDelta : NSNumber
    @NSManaged var longitudeDelta: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("MapRegion", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        centerLatitude = dictionary[Keys.Latitude] as! Double
        centerLongitude = dictionary[Keys.Longitude] as! Double
        latitudeDelta = dictionary[Keys.LatDelta] as! Double
        longitudeDelta = dictionary[Keys.LongDelta] as! Double
    }
    
    func getMapRegion() -> MKCoordinateRegion {
        
        let lat = centerLatitude as Double
        let long = centerLongitude as Double
        let latDelta = latitudeDelta as Double
        let longDelta = longitudeDelta as Double
        
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        let span = MKCoordinateSpanMake(latDelta, longDelta)
        
        return MKCoordinateRegionMake(coordinate, span)
    }
}
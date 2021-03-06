//
//  Picture.swift
//  Virtual Tourist
//
//  Created by Imanol Viana Sánchez on 3/3/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit
import CoreData

class Picture : NSManagedObject {
 
    struct Keys {
        static let Title = "title"
        static let ImageURL = "imageURL"
    }

    
    @NSManaged var title : String?
    @NSManaged var imageURL : String?
    @NSManaged var imagePath : String?
    @NSManaged var pin : Pin?

    var image : UIImage? {
        get { return ImageCache.sharedInstance().imageWithIdentifier(imagePath) }
        set { ImageCache.sharedInstance().storeImage(newValue, withIdentifier: imagePath!) }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, imageURL: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let url = NSURL(string: imageURL)
        self.title = title
        self.imageURL = imageURL
        self.imagePath = url?.lastPathComponent
    }
}
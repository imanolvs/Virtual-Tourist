//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Imanol Viana Sánchez on 3/3/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var textLabel: UILabel!
    
    var tapPinToDelete: Bool = false
    var mapRegion : MapRegion!
    
    var sharedContext: NSManagedObjectContext { return CoreDataStackManager.sharedInstance().managedObjectContext }
    
    // MARK: Fetched Results Controller for Pin Objects
    lazy var fetchedResultsController : NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()

    // MARK: Fetched Results Controller for MapRegion Objects
    lazy var fetchedResultsControllerMapRegion : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "MapRegion")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "centerLatitude", ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        
        // Fetched Results Controller Delegate not specified in this Class, so the delegate will be the default one.
        fetchedResultsController.delegate = self
        fetchedResultsControllerMapRegion.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch { print(error) }
    
        restoreFechedPins()
        
        do {
            try fetchedResultsControllerMapRegion.performFetch()
        } catch { print(error) }
        
        restoreMapRegion()
    }
    
    // MARK: Swap between Add/Delete Pins on Map States
    @IBAction func editPinsOnMap(sender: UIBarButtonItem) {
        
        if tapPinToDelete == true {
            self.navigationItem.rightBarButtonItem!.title = "Edit"
            tapPinToDelete = false
            textLabel.hidden = true
            mapView.frame.origin.y += textLabel.frame.height
        }
        else {
            self.navigationItem.rightBarButtonItem!.title = "Done"
            tapPinToDelete = true
            textLabel.hidden = false
            mapView.frame.origin.y -= textLabel.frame.height
        }
    }
    
    var firstDrop : Bool = true
    var annotation = MKPointAnnotation()
    // MARK: Try to add a pin when a Long Press Gesture is performed
    @IBAction func longpressAddAnnotation(sender: UILongPressGestureRecognizer) {

        if tapPinToDelete == true { return }

        switch sender.state {
        case .Began:
            firstDrop = true
            let point = sender.locationInView(self.mapView)
            let location : CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: self.mapView)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
            self.annotation = annotation
        case .Changed:
            firstDrop = false
            mapView.removeAnnotation(self.annotation)

            let point = sender.locationInView(self.mapView)
            let location : CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: self.mapView)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
            self.annotation = annotation
        case .Ended:
            firstDrop = false
            let dictionary = [Pin.Keys.Latitude : self.annotation.coordinate.latitude,
                Pin.Keys.Longitude : self.annotation.coordinate.longitude]
            let pin = Pin(dictionary: dictionary, context: sharedContext)
            getPicturesFromFlickr(pin)
            CoreDataStackManager.sharedInstance().saveContext()
        default:
            break
        }
    }
    
    // MARK: Method for restoring Fetched Pins and the Map Region
    func restoreFechedPins() {
        
        let fetchedPins = fetchedResultsController.fetchedObjects as! [Pin]
        for pin in fetchedPins { mapView.addAnnotation(pin) }
    }
    
    func restoreMapRegion() {
        
        let fetchedObjects = fetchedResultsControllerMapRegion.fetchedObjects as! [MapRegion]
        if fetchedObjects.count == 0 { return }
        
        mapRegion = fetchedObjects[0]
        mapView.region = mapRegion.getMapRegion()
    }
}

// MARK: MapView Delegate methods
extension MapViewController {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        
        pinView.pinTintColor = UIColor.redColor()
        pinView.draggable = false
        pinView.canShowCallout = false
        firstDrop ? (pinView.animatesDrop = true) : (pinView.animatesDrop = false)
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        let pin = findSelectedPin(view.annotation!.coordinate, context: sharedContext) as! Pin

        if tapPinToDelete == true {
            mapView.removeAnnotation(view.annotation!)
            sharedContext.deleteObject(pin)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        else {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PhotosCollectionViewController") as! PhotosCollectionViewController

            controller.pin = pin
            
            navigationController?.pushViewController(controller, animated: true)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if let _ = mapRegion {
            sharedContext.deleteObject(mapRegion)
        }
        let latitude = mapView.region.center.latitude
        let longitude = mapView.region.center.longitude
        let latDelta = mapView.region.span.latitudeDelta
        let longDelta = mapView.region.span.longitudeDelta
        let dictionary = [
            MapRegion.Keys.Latitude : latitude,
            MapRegion.Keys.Longitude : longitude,
            MapRegion.Keys.LatDelta : latDelta,
            MapRegion.Keys.LongDelta : longDelta]
        
        mapRegion = MapRegion(dictionary: dictionary, context: sharedContext)
        CoreDataStackManager.sharedInstance().saveContext()
    }
}

extension MapViewController {
    
    // MARK: Method for performing the Photos Request by Flickr Search Method
    private func getPicturesFromFlickr(pin: Pin) {
        
        let parameters = getMethodParameters(pin)
        
        FlickrClient.sharedInstance().downloadPhotos(parameters) { (photoArray, error) in
            
            guard error == nil else {
                print(error)
                return
            }
            
            for photoDictionary in photoArray! {
                let title = photoDictionary[FlickrConstants.FlickrResponseKeys.Title] as! String
                let imageURL = photoDictionary[FlickrConstants.FlickrResponseKeys.MediumURL] as! String
                let picture = Picture(title: title, imageURL: imageURL, context: self.sharedContext)
                picture.pin = pin
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
    }
    
    // MARK: Method for finding the Pin selected and its attributes through its coordinates and the context
    private func findSelectedPin(coordinates: CLLocationCoordinate2D, context: NSManagedObjectContext) -> AnyObject? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        
        // Build a predicate using latitude and longitude and link it to the fetchRequest
        let latitude = coordinates.latitude as NSNumber
        let longitude = coordinates.longitude as NSNumber
        let latPredicate = NSPredicate(format: "latitude == %@", latitude)
        let longPredicate = NSPredicate(format: "longitude == %@", longitude)
        let predicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: [latPredicate, longPredicate])
        fetchRequest.predicate = predicate
        
        // Execute the fetchRequest!
        var targetPin: AnyObject? = nil
        do {
            targetPin = try context.executeFetchRequest(fetchRequest)
        } catch { print(error) }
        
        return targetPin![0] as! Pin    //This is the pin we are looking for!
    }
}

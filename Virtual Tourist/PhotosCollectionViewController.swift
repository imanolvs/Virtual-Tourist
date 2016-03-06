//
//  PhotosCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Imanol Viana Sánchez on 3/3/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotosCollectionViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
 
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton : UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var sharePicturesButton: UIBarButtonItem!
    @IBOutlet weak var noImagesFoundLabel: UILabel!
    
    var isSelectingPicures: Bool = false
    var pin: Pin!
    var selectedIndexes = [NSIndexPath]()
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!

    
    // MARK: Shared Context
    var sharedContext: NSManagedObjectContext { return CoreDataStackManager.sharedInstance().managedObjectContext }
    
    // MARK: Fetched Results Controller
    lazy var fetchedResultController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Picture")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Add an Select/Cancel Button in the naviagator bar as Right Button. Initialize the rest of buttons and mapview
        let rightBarButton = UIBarButtonItem(title: "Select", style: .Done, target: self, action: Selector("willSelectPictures:"))
        navigationItem.rightBarButtonItem = rightBarButton
        trashButton.enabled = false
        sharePicturesButton.enabled = false
        
        let region = MKCoordinateRegionMake(pin.coordinate, MKCoordinateSpanMake(0.025, 0.025))
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch { print(error) }
        
        if fetchedResultController.fetchedObjects?.count > 0 {
            performUIUpdates { self.newCollectionButton.enabled = false }
        }
        else {
            performUIUpdates { self.noImagesFoundLabel.hidden = false }
        }
        
        performUIUpdates {
            self.mapView.addAnnotation(self.pin)
            self.mapView.centerCoordinate = self.pin.coordinate
            self.mapView.setRegion(region, animated: false)
            self.collectionView.backgroundColor = UIColor.whiteColor()
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let sideFrame = CGFloat(self.view.frame.width / 3 - 2 * 0.5)
        
        flowLayout.minimumInteritemSpacing = 0.5
        flowLayout.minimumLineSpacing = 0.5
        flowLayout.itemSize = CGSize(width: sideFrame, height: sideFrame)
        flowLayout.invalidateLayout()
    }
    
    // MARK: Refresh the Collection View with a New Picture Collection
    @IBAction func newCollectionUpdate(sender: UIBarButtonItem) {

        newCollectionButton.enabled = false
        noImagesFoundLabel.hidden = true
        deletePhotos()
        collectionView.reloadData()
        
        performPhotosRequest() { (success, error) in
            
            if success == false {
                print(error)
                performUIUpdates{ self.noImagesFoundLabel.hidden = false }
            }
            performUIUpdates { self.newCollectionButton.enabled = true }
        }
    }
    
    // MARK: Swap between Select/Show the pictures
    @IBAction func willSelectPictures(sender: UIBarButtonItem) {
        
        if isSelectingPicures == false
        {
            navigationItem.rightBarButtonItem?.title = "Cancel"
            trashButton.enabled = true
            sharePicturesButton.enabled = true
            newCollectionButton.enabled = false
            isSelectingPicures = true
        }
        else
        {
            navigationItem.rightBarButtonItem?.title = "Select"
            trashButton.enabled = false
            sharePicturesButton.enabled = false
            newCollectionButton.enabled = true
            isSelectingPicures = false
            let cloneOfSelectedIndexes = selectedIndexes
            selectedIndexes.removeAll()
            collectionView.reloadItemsAtIndexPaths(cloneOfSelectedIndexes)
        }
    }
    
    // MARK: Delete the selected pictures
    @IBAction func deleteSelectedPictures(sender: UIBarButtonItem) {
        
        let cloneSelectedIndexes = selectedIndexes
        selectedIndexes.removeAll()
        for indexPath in cloneSelectedIndexes {
            let object = fetchedResultController.objectAtIndexPath(indexPath) as! Picture
            sharedContext.deleteObject(object)
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: Share the selected pictures
    @IBAction func shareSelectedPictures(sender: UIBarButtonItem) {
        
        let activityController: UIActivityViewController
        var selectedImages : [UIImage] = []
        for indexPath in selectedIndexes {
            let pic = fetchedResultController.objectAtIndexPath(indexPath) as! Picture
            selectedImages.append(pic.image!)
        }
        activityController = UIActivityViewController(activityItems: selectedImages, applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
        
        activityController.completionWithItemsHandler = { (activity, success, items, error) in
            
            if success
            {
                self.dismissViewControllerAnimated(true, completion: nil)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
}

// MARK: Collection View Delegate Methods
extension PhotosCollectionViewController {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PictureCollecionViewCell", forIndexPath: indexPath) as! PictureCollecionViewCell
        let picture = fetchedResultController.objectAtIndexPath(indexPath) as! Picture
        
        configureCell(cell, withPicture: picture, indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if isSelectingPicures == true {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PictureCollecionViewCell
            if let index = selectedIndexes.indexOf(indexPath) {
                cell.imageView.alpha = 1
                cell.checkmarkImageView.image = nil
                selectedIndexes.removeAtIndex(index)
            }
            else {
                cell.imageView.alpha = 0.2
                cell.checkmarkImageView.image = UIImage(named: "OKImage")
                selectedIndexes.append(indexPath)
            }
        }
        else {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
            let picture = fetchedResultController.objectAtIndexPath(indexPath) as! Picture
            
            controller.image = picture.image!
            controller.text = picture.title!
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

// MARK: Fetched Results Controller Delegate Methods
extension PhotosCollectionViewController {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
        
        if fetchedResultController.fetchedObjects?.count == 0 {
            noImagesFoundLabel.hidden = false
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        default:
            return
        }
    }
}

extension PhotosCollectionViewController {
    
    //MARK: Method forr configuring the collection view cells
    private func configureCell(cell: PictureCollecionViewCell, withPicture picture: Picture, indexPath: NSIndexPath) {
        
        cell.imageView.contentMode = .ScaleToFill
        cell.activityIndicator.startAnimating()
        cell.backgroundColor = UIColor.grayColor()
        
        if picture.image != nil {
            performUIUpdates {
                cell.activityIndicator.stopAnimating()
                cell.imageView.image = picture.image
            }
        }
        else {
            
            let task = FlickrClient.sharedInstance().downloadDataImage(picture.imageURL!) { (data, error) in
                
                guard error == nil else {
                    print(error)
                    return
                }
                
                if let data = data {
                    
                    let image = UIImage(data: data)
                    picture.image = image
                    performUIUpdates {
                        cell.activityIndicator.stopAnimating()
                        cell.imageView.image = image
                    }
                }
            }
            
            cell.taskToCancelifCellIsReused = task
        }
        
        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.imageView.alpha = 0.2
            cell.checkmarkImageView.image = UIImage(named: "OKImage")
        }
        else {
            cell.imageView.alpha = 1
            cell.checkmarkImageView.image = nil
        }
    }
    
    // MARK: Method for performing the Photos Request by Flickr Search Method
    private func performPhotosRequest(completionHandler: (success: Bool, error: String?) -> Void) {
        let parameters = getMethodParameters(pin)
        
        FlickrClient.sharedInstance().downloadPhotos(parameters) { (photoArray, error) in
            
            guard error == nil else {
                completionHandler(success: false, error: error)
                return
            }
            
            for photoDictionary in photoArray! {
                let title = photoDictionary[FlickrConstants.FlickrResponseKeys.Title] as! String
                let imageURL = photoDictionary[FlickrConstants.FlickrResponseKeys.MediumURL] as! String
                let picture = Picture(title: title, imageURL: imageURL, context: self.sharedContext)
                picture.pin = self.pin
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
            completionHandler(success: true, error: nil)
        }
    }
    
    // MARK: Method for deleting all pictures
    private func deletePhotos() {
        
        for object in fetchedResultController.fetchedObjects! {
            let obj = object as! NSManagedObject
            sharedContext.deleteObject(obj)
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
}
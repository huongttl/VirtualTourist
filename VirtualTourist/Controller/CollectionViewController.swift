//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Huong Tran on 5/16/20.
//  Copyright © 2020 RiRiStudio. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController {

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pinAnnotation: MKAnnotation!
    var pin: PinData!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<PhotoData>!
    var photos: [PhotoData] = [PhotoData]()
    var isPhotoStored = false
    
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 20.0, bottom: 5.0, right: 20.0)
    let itemsPerRow: CGFloat = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mapView.delegate = self
        mapView.addAnnotation(pinAnnotation)
        let centerLocation = CLLocationCoordinate2D(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude)
        mapView.setCenter(centerLocation, animated: true)
        
        collectionView.delegate = self
        
        setUpFetchedResultsController()
        print("setup isPhotoStored: \(isPhotoStored)")
        if isPhotoStored == false {
            generatePhotos()
        } else {
            setUpPhotos()
        }
        
//        if fetchedResultsController.fetchedObjects == nil || fetchedResultsController.fetchedObjects?.count == 0 {
//            print("fet NIl")
//            isPhotoStored = false
//            generatePhotos()

//        } else {
//            isPhotoStored = true
//            print("set up PHOTOS")
////            setUpPhotos()
//        }
//        updateFlowLayout(view.frame.size)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        self.collectionView.collectionViewLayout.invalidateLayout()
//    }
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: {(context)in
//            self.collectionView.collectionViewLayout.invalidateLayout()
//        }, completion: nil)
//    }
    
    func addPhotos() {
        for photo in photos {
            let photoToSave = PhotoData(context: dataController.viewContext)
            photoToSave.pin = pin
            photoToSave.image = photo.image
            try? dataController.viewContext.save()
        }
    }
    
    func addPhoto(photo: Data) {
        let photoToSave = PhotoData(context: dataController.viewContext)
        photoToSave.pin = pin
        photoToSave.image = photo
        try? dataController.viewContext.save()
    }
    
    func generatePhotos() {
        _ = FlickrClient.getPhotoURLs(lat: pinAnnotation.coordinate.latitude, lon: pinAnnotation.coordinate.longitude) {
            (response, error) in
            if error != nil {
                self.showLoadFailure(message: error?.localizedDescription ?? "")
            } else {
                DataModel.photos = (response?.photos.photo)!
                print("count photo \(DataModel.photos.count)")
//                self.collectionView.reloadData()
                self.collectionView.reloadData()
                self.collectionView.reloadInputViews()
                
            }
            
        }
    }
    
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<PhotoData> = PhotoData.fetchRequest()
//        let sortDesriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "pin == %@", pin!)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
//            print("fetchedResultsController.fetchedObjects?.count: \(fetchedResultsController.fetchedObjects?.count)")
            if let data = fetchedResultsController.fetchedObjects {
                if data.count == 0 {
                    isPhotoStored = false
                    print("isPhotoStored: \(isPhotoStored)")
                    print("data count: \(data.count)")
//                    photos = data
                } else {
                    print("data count: \(data.count)")
                    isPhotoStored = true
                    photos = data
                    print("isPhotoStored: \(isPhotoStored)")
                }
                
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
//            generatePhotos()
        }
    }
    
    func setUpPhotos() {
//        if let data = fetchedResultsController.fetchedObjects, data.count > 0 {
//            photos = data
//            print("photo num: \(data.count)")
//            self.collectionView.reloadData()
//        }
        print("setUpPhoto should be running")
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        generatePhotos()
    }
    
    func showLoadFailure(message: String) {
        let alertVC = UIAlertController(title: "Load Student Location Failed", message: message, preferredStyle: .alert)
        print(message)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
//    func updateFlowLayout(_ withSize: CGSize) {
//
//        let landscape = withSize.width > withSize.height
//
//        let space: CGFloat = landscape ? 5 : 3
//        let items: CGFloat = landscape ? 2 : 3
//
//        let dimension = (withSize.width - ((items + 1) * space)) / items
//
//        flowLayout?.minimumInteritemSpacing = space
//        flowLayout?.minimumLineSpacing = space
//        flowLayout?.itemSize = CGSize(width: dimension, height: dimension)
//        flowLayout?.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
//    }
}

extension CollectionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinId = "PinAnnotationIdentifier"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.annotation = annotation
        pinView.rightCalloutAccessoryView = UIButton(type: .infoLight)
//        print("latitude: \(annotation.coordinate.latitude), longitude: \(annotation.coordinate.longitude)")
        return pinView
    }
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Collection item num: \(DataModel.photos.count)")
        return DataModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
//        if let fetchResult = fetchedResultsController.fetchedObjects, fetchResult.count > 0 {
//            // Load photos from CoreDate if any
//            let photo = fetchedResultsController.object(at: indexPath)
//            if let data = photo.image {
//                cell.imageView.image = UIImage(data: data)
////                let p = data as? PhotoData
//
//            }
//        } else {
            // Call Flickr API if there's no saved photos
            let photo = DataModel.photos[indexPath.row]
            FlickrClient.downloadPhoto(farmId: photo.farm, serverId: photo.server, id: photo.id, secret: photo.secret) {
                data, error in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                cell.imageView.image = image
//                let p = PhotoData(entity: data, insertInto: dataController.viewContext)
//                let p = PhotoData(context: self.dataController.viewContext)
//                p.image = data
//                p.addToPhotos(self.pin)
//                try? self.dataController.viewContext.save()
                self.addPhoto(photo: data)
                self.isPhotoStored = true
            }
//        }
        return cell
    }
    
    // Todo
}

extension CollectionViewController: NSFetchedResultsControllerDelegate {
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    //        tableView.beginUpdates()
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    //        tableView.endUpdates()
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch type {
            case .insert:
    //            tableView.insertRows(at: [newIndexPath!], with: .fade)
                print("todo insert")
            case .delete:
    //            tableView.deleteRows(at: [indexPath!], with: .fade)
                print("todo delete")
            case .update:
    //            tableView.reloadRows(at: [indexPath!], with: .fade)
                print("todo update")
            default:
                break
            }
        }

}
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = sectionInsets.left * (itemsPerRow + 1)
        let cellWidth = (view.frame.width - padding) / itemsPerRow
        print("width: \(cellWidth)")
        return CGSize(width: cellWidth, height: cellWidth)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
//    func collectionView
    
}


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

class CollectionViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin: PinData!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<PhotoData>!
    var photos: [PhotoData] = [PhotoData]()
    var isPhotoStored = false
    
    var photoCount = 0
    
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 20.0, bottom: 5.0, right: 20.0)
    let itemsPerRow: CGFloat = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        let centerLocation = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)
        mapView.setCenter(centerLocation, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin.lat
        annotation.coordinate.longitude = pin.lon
        mapView.addAnnotation(annotation)
        
        collectionView.delegate = self
        setUpFetchedResultsController()
        if isPhotoStored == false {
            setUpNewCollectionButton(isEnable: true)
            generatePhotos()
        } else {
            setUpNewCollectionButton(isEnable: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    func generatePhotos() {
        _ = FlickrClient.getPhotoURLs(lat: pin.lat, lon: pin.lon) {
            (response, error) in
            if error != nil {
                self.showLoadFailure(message: error?.localizedDescription ?? "")
            } else {
                DataModel.photos = (response?.photos.photo)!
                if DataModel.photos.count == 0 {
                    self.showLoadFailure(message: "There's no photo taken. Try again!")
                    return
                }
                self.collectionView.reloadData()
                self.collectionView.reloadInputViews()
            }
        }
    }
    
    func deletePhoto(index: NSIndexPath) {
        let photoToDelete = fetchedResultsController.object(at: index as IndexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
    
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<PhotoData> = PhotoData.fetchRequest()
        fetchRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        if let data = fetchedResultsController.fetchedObjects {
            if data.count == 0 {
                isPhotoStored = false
            } else {
                isPhotoStored = true
                photos = data
                photoCount = data.count
            }
        }
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        if let result = fetchedResultsController.fetchedObjects {
            for photo in result {
                dataController.viewContext.delete(photo)
            }
        }
        generatePhotos()
    }
    
    func setUpNewCollectionButton(isEnable: Bool) {
        newCollectionButton.isEnabled = isEnable
    }
    
    func showLoadFailure(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        print(message)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

extension CollectionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinId = "PinAnnotationIdentifier"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.annotation = annotation
        pinView.rightCalloutAccessoryView = UIButton(type: .infoLight)
        return pinView
    }
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Collection item num: \(DataModel.photos.count)")
        if isPhotoStored {
            return fetchedResultsController.fetchedObjects!.count
        } else {
            return DataModel.photos.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(named: "AppIcon")
        if isPhotoStored {
            let photo = fetchedResultsController.object(at: indexPath)
            if let data = photo.image {
                cell.imageView.image = UIImage(data: data)
            }
        } else {
            let photo = DataModel.photos[indexPath.row]
            FlickrClient.downloadPhoto(farmId: photo.farm, serverId: photo.server, id: photo.id, secret: photo.secret) {
                data, error in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                cell.imageView.image = image
                let p = PhotoData(context: self.dataController.viewContext)
                p.image = data
                p.pin = self.pin
                try? self.dataController.viewContext.save()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])
        deletePhoto(index: indexPath as NSIndexPath)
        collectionView.reloadData()
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = sectionInsets.left * (itemsPerRow + 1)
        let cellWidth = (view.frame.width - padding) / itemsPerRow
        return CGSize(width: cellWidth, height: cellWidth)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


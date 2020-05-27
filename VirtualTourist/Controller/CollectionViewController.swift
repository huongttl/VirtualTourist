//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Huong Tran on 5/16/20.
//  Copyright © 2020 RiRiStudio. All rights reserved.
//

import UIKit
import MapKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pinAnnotation: MKAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mapView.delegate = self
        mapView.addAnnotation(pinAnnotation)
        let centerLocation = CLLocationCoordinate2D(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude)
        mapView.setCenter(centerLocation, animated: true)
        
        collectionView.delegate = self
        
        _ = FlickrClient.getPhotoURLs(lat: pinAnnotation.coordinate.latitude, lon: pinAnnotation.coordinate.longitude) {
            (response, error) in
            if error != nil {
                self.showLoadFailure(message: error?.localizedDescription ?? "")
            } else {
                DataModel.photos = (response?.photos.photo)!
                print("count student \(DataModel.photos.count)")
                self.collectionView.reloadData()
                //                self.viewAnnotation()
            }
            
        }
    }
    
    func showLoadFailure(message: String) {
        let alertVC = UIAlertController(title: "Load Student Location Failed", message: message, preferredStyle: .alert)
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
        print("latitude: \(annotation.coordinate.latitude), longitude: \(annotation.coordinate.longitude)")
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
        let photo = DataModel.photos[indexPath.row]
        FlickrClient.downloadPhoto(farmId: photo.farm, serverId: photo.server, id: photo.id, secret: photo.secret) {
            data, error in
            guard let data = data else {
                return
            }
            let image = UIImage(data: data)
            cell.imageView.image = image
        }
        
        return cell
    }
    
    // Todo
}

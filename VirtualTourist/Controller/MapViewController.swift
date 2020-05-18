//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Huong Tran on 5/16/20.
//  Copyright © 2020 RiRiStudio. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 0.6
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("pin selected")
        print("\(view.annotation?.coordinate.latitude); \(view.annotation?.coordinate.longitude)")
        let collectionVC = storyboard?.instantiateViewController(identifier: "CollectionViewController") as! CollectionViewController
        collectionVC.pinAnnotation = view.annotation
        navigationController?.pushViewController(collectionVC, animated: true)
    }
}

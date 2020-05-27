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
    var centerPos = CLLocationCoordinate2D()
    var zoomRange = MKCoordinateSpan()
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 0.6
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        checkMapSetting()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapSetting()
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
    
    func checkMapSetting() {
        print("aha")
        print(UserDefaults.standard.object(forKey: "CenterPosLat"))
        if UserDefaults.standard.object(forKey: "CenterPosLat") != nil {
            mapView.setCenter(CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "CenterPosLat"), longitude: UserDefaults.standard.double(forKey: "CenterPosLon")), animated: true)
            mapView.setCameraZoomRange(MKMapView.CameraZoomRange(maxCenterCoordinateDistance: UserDefaults.standard.double(forKey: "ZoomRange")) , animated: true)
            let center = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "CenterPosLat"), longitude: UserDefaults.standard.double(forKey: "CenterPosLon"))
            let zoom = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "ZoomRangeLat"), longitudeDelta: UserDefaults.standard.double(forKey: "ZoomRangeLon"))
            mapView.setRegion(MKCoordinateRegion(center: center, span: zoom), animated: true)
        }
    }
    
    func saveMapSetting() {
        UserDefaults.standard.set(centerPos.latitude, forKey: "CenterPosLat")
        UserDefaults.standard.set(centerPos.longitude, forKey: "CenterPosLon")
        UserDefaults.standard.set(zoomRange.latitudeDelta, forKey: "ZoomRangeLat")
        UserDefaults.standard.set(zoomRange.longitudeDelta, forKey: "ZoomRangeLon")
        UserDefaults.standard.synchronize()
        print("saved")
//        print(UserDefaults.standard.double(forKey: "CenterPosLat"))
//        print(UserDefaults.standard.double(forKey: "CenterPosLon"))
//        print(UserDefaults.standard.double(forKey: "ZoomRangeLat"))
//        print(UserDefaults.standard.double(forKey: "ZoomRangeLon"))
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        centerPos = mapView.centerCoordinate
        zoomRange = mapView.region.span
        print("centerPos: \(centerPos)")
        print("rangeZoom: \(zoomRange)")
        
    }
}

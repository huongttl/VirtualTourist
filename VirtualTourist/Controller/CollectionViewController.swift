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
    
    var pinAnnotation: MKAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mapView.delegate = self
        mapView.addAnnotation(pinAnnotation)
        let centerLocation = CLLocationCoordinate2D(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude)
        mapView.setCenter(centerLocation, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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

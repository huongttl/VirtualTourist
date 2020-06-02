//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Huong Tran on 5/16/20.
//  Copyright © 2020 RiRiStudio. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    var centerPos = CLLocationCoordinate2D()
    var zoomRange = MKCoordinateSpan()
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController : DataController!
    var fetchedResultsController : NSFetchedResultsController<PinData>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Map view gesture
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 0.6
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        checkMapSetting()
        setUpFetchedResultsController()
        setUpPins()
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
            addPin(lat: coordinate.latitude, lon: coordinate.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            print("after saving pin: \(fetchedResultsController.fetchedObjects?.count)")
        }
    }
    
    func addPin(lat: Double, lon: Double) {
        let pin = PinData(context: dataController.viewContext)
        pin.lat = lat
        pin.lon = lon
        try? self.dataController.viewContext.save()
        print("after saving pin: \(fetchedResultsController.fetchedObjects?.count)")
    }
    
    func setUpPins() {
        var annotiations = [MKPointAnnotation]()
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins as [PinData] {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = pin.lat
                annotation.coordinate.longitude = pin.lon
                annotiations.append(annotation)
            }
            mapView.addAnnotations(annotiations)
        }
        
    }
    
    func checkMapSetting() {
        if UserDefaults.standard.object(forKey: "CenterPosLat") != nil {
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
    }
    
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<PinData> = PinData.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
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
//        print("\(view.annotation?.coordinate.latitude); \(view.annotation?.coordinate.longitude)")
        let collectionVC = storyboard?.instantiateViewController(identifier: "CollectionViewController") as! CollectionViewController
//        collectionVC.pinAnnotation = view.annotation
        collectionVC.dataController = dataController
//        let pin = PinData(context: dataController.viewContext)
//        pin.lat = (view.annotation?.coordinate.latitude)!
//        pin.lon = (view.annotation?.coordinate.longitude)!
//        print("selected index: \(fetchedResultsController.indexPath(forObject: pin))")
//        fetchedResultsController.o
//        try? dataController.viewContext.save()
        if let pin = searchPinData(lat: (view.annotation?.coordinate.latitude)!, lon: (view.annotation?.coordinate.longitude)!) {
            collectionVC.pin = pin
        } else {
            print("Cannot access pin")
        }
        
//        collectionVC.pin = view.annotation
//        fetchedResultsController.indexPath(forObject: view)
        mapView.deselectAnnotation(view.annotation, animated: true)
        navigationController?.pushViewController(collectionVC, animated: true)
    }
    
    func searchPinData(lat: Double, lon: Double) -> PinData? {
        let latToCompare = NSNumber(value: lat)
        let lonToCompare = NSNumber(value: lon)
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins {
                let latNumber = NSNumber(value: pin.lat)
                let lonNumber = NSNumber(value: pin.lon)
                if latToCompare == latNumber && lonToCompare == lonNumber {
                    return pin
                }
            }
        }
        print("fetch count")
        print(fetchedResultsController.fetchedObjects?.count)
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        centerPos = mapView.centerCoordinate
        zoomRange = mapView.region.span
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////        tableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////        tableView.endUpdates()
//    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
////            tableView.insertRows(at: [newIndexPath!], with: .fade)
//            print("todo")
//        case .delete:
////            tableView.deleteRows(at: [indexPath!], with: .fade)
//            print("todo")
//        case .update:
////            tableView.reloadRows(at: [indexPath!], with: .fade)
//            print("todo")
//        default:
//            break
//        }
//    }
}

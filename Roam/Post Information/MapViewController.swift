//
//  MapViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/20/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit
import MapKit

class PostLocation : NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title : String?
    init(title:String?, coordinate:CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var locations = [String:[String:Double]]()
    var allAnnotations = [PostLocation]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    let kSpanLatitudeDelta = 0.027
    let kSpanLongitudeDelta = 0.027
    let kSpanLatitudeDeltaZoom = 0.002
    let kSpanLongitudeDeltaZoom = 0.002
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    func configure(_ locations: [String:[String:Double]]?) {
        if let locationsSent = locations {
            self.locations = locationsSent
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        plot()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is PostLocation:
            return annotationView(forPostLocation : annotation as! PostLocation)
        default:
            return nil
        }
    }
    
    func annotationView(forPostLocation postLocation :PostLocation) -> MKAnnotationView {
        let identifier = "Location"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: postLocation, reuseIdentifier: identifier)
            view.pinTintColor = MKPinAnnotationView.redPinColor()
            view.animatesDrop = true
            view.canShowCallout = true
        }
        
        return view
    }
    
    func plot(changeRegion : Bool = true) {

        for location in self.locations.keys {
            let coordinate = CLLocation(latitude: self.locations[location]!["lat"]!, longitude: self.locations[location]!["long"]!).coordinate
            let title = location
                
            let postLocation = PostLocation(title: title, coordinate: coordinate)
            self.allAnnotations.append(postLocation)
            self.mapView.addAnnotation(postLocation)
        }
        if allAnnotations.count > 0 {
            self.mapView.showAnnotations(allAnnotations, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }

}

//
//  HouseMapController.swift
//  TreatFinder
//
//  Created by Keaton Burleson on 9/29/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class HouseMapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    @IBOutlet weak var mapView: MKMapView?
    
    private var locationManager: CLLocationManager? = nil
    public var currentUserLocation: CLLocation? = nil
    
    override func viewDidLoad() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView?.delegate = self
        mapView?.showsUserLocation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(locations.last != nil){
            self.currentUserLocation = locations.last
            let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            let region = MKCoordinateRegion(center: (currentUserLocation?.coordinate)!, span: span)
            self.mapView?.setRegion(region, animated: true)
        }
    }
}

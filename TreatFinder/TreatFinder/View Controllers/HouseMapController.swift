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
import Pulley

class HouseMapController: UIViewController, HouseManagerDelegate, HouseManagerUpdateDelegate, KABMapViewDelegate, PulleyDelegate {

    @IBOutlet weak var mapView: KABMapView?
    private var houseManager = HouseManager()
    private var previousLocations: [CLLocation] = []

    override func viewDidLoad() {
        houseManager.delegate = self
        houseManager.updateDelegate = self
        setupMapView()
    }
    
    private func setupMapView() {
        mapView?.showsUserLocation = true
     //   mapView?.userTrackingMode = .followWithHeading
        mapView?.mapType = .standard
        mapView?.kabDelegate = self
    }

    func didSelectHouse(data: HouseModel) {
        if let drawer = self.parent as? PulleyViewController
        {
            let drawerContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "infoCard")
            (drawerContent as! InfoCardController).house = data
            (drawerContent as! InfoCardController).currentUID = self.houseManager.userId
            drawer.setDrawerContentViewController(controller: drawerContent, animated: true)
            drawer.setDrawerPosition(position: .partiallyRevealed, animated: true)
        }
    }

    @IBAction func addHouse(sender: UIButton) {
        if(houseManager.isLoggedIn == true) {
            let currentUserLocation = houseManager.currentUserLocation
            sender.isHidden = true
            var house = HouseModel(userID: houseManager.userId!)
            let houseLocation = HousePoint(latitude: (currentUserLocation?.coordinate.latitude)!, longitude: (currentUserLocation?.coordinate.longitude)!)

            house.name = "Test House"

            house.location = houseLocation
            house.userID = houseManager.userId!
            houseManager.addHouse(house, forUserID: "testID")
        } else {
            print("Errorrrr")
        }
    }

    func locationUpdated(currentLocation: CLLocation) {
        if(previousLocations.count < 4) {
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
            mapView?.setRegion(region, animated: true)
            previousLocations.append(currentLocation)
        }
    }

    func headingUpdated(heading: CLHeading) {
       // mapView?.camera.heading = heading.magneticHeading
        // mapView?.setCamera((mapView?.camera)!, animated: true)
    }


    func locationWasUpdated() {
        print("loc updated")
    }
    
    func update(houses: [HouseModel]) {
        for house in houses {
            DispatchQueue.main.async {
                if(self.houseManager.userOwnsHouse(house: house)) {
                    self.mapView?.dropPin(coordinate: house.location!.getCoordinate(), title: "You house", house: house)
                } else {
                    self.mapView?.dropPin(coordinate: house.location!.getCoordinate(), title: house.name!, house: house)
                }
            }
        }
    }
}

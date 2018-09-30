//
//  HouseManager.swift
//  TreatFinder
//
//  Created by Keaton Burleson on 9/29/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase
import CoreLocation

class HouseManager: NSObject, CLLocationManagerDelegate {
    public var locationManager: CLLocationManager!
    public var db: Firestore? = nil
    public var userId: String? = nil
    public var delegate: HouseManagerDelegate?
    public var updateDelegate: HouseManagerUpdateDelegate?

    private(set) public var previousLocations: [CLLocation] = []
    private(set) public var currentUserLocation: CLLocation? = nil
    private(set) public var isLoggedIn = false

    override init() {
        super.init()
        buildLocationManager()

        let _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil) {
                self.userId = user?.uid
                self.isLoggedIn = true
                print("HouseManager initialized with user")
            }
        }

        self.setupDatabaseReference()
        self.subscribeToHouseUpdates()
    }

    // Watch for house changes
    private func subscribeToHouseUpdates() {
        var houses: [HouseModel] = []
        db!.collection("houses").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            for document in documents {
                do {
                    var house = try FirestoreDecoder().decode(HouseModel.self, from: document.data())
                    house.documentID = document.documentID
                    houses.append(house)
                } catch _ {
                    print("Unable to parse a house")
                    self.db?.collection("houses").document(document.documentID).delete()
                }
            }
            self.updateDelegate?.update(houses: houses)
        }
    }

    // Setup the database ref
    private func setupDatabaseReference() {
        db = Firestore.firestore()
        let settings = db?.settings
        settings?.areTimestampsInSnapshotsEnabled = true
        db?.settings = settings!
    }

    // Make a CLLocationManager instance
    private func buildLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self

        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations.first!
        if (locations.count > 1) {
            currentUserLocation = locations.last
        }
        updateDelegate?.locationWasUpdated()
        guard let delegate = delegate
            else {
                return
        }


        delegate.locationUpdated!(currentLocation: currentUserLocation!)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard let delegate = delegate
            else {
                return
        }
        delegate.headingUpdated!(heading: newHeading)
    }

    func addHouse(_ house: HouseModel, forUserID: String) {
        let data = try! FirebaseEncoder().encode(house)
        db!.collection("houses").addDocument(data: data as! [String: Any])
    }

    // FUUUK
    func userOwnsHouse(house: HouseModel) -> Bool {
        return (house.userID.lowercased() == self.userId!.lowercased())
    }

    func updateRating(house: HouseModel, rating: Double) {
        guard let id = house.documentID
            else {
                print("ur fuked")
                return
        }

        var uids: [String] = []
        uids.append(contentsOf: house.submittedRatings)
        uids.append(NSUUID().uuidString.lowercased())

        var ratings: [Double] = []
        ratings.append(contentsOf: house.ratings)
        ratings.append(rating)

        db!.collection("houses").document(id).updateData(["ratings": ratings, "submittedRatings": uids])
    }

}

@objc protocol HouseManagerDelegate {
    @objc optional func headingUpdated(heading: CLHeading)
    @objc optional func locationUpdated(currentLocation: CLLocation)
}

protocol HouseManagerUpdateDelegate {
    func update(houses: [HouseModel])
    func locationWasUpdated()
}

//
//  HouseListController.swift
//  TreatFinder
//
//  Created by Keaton Burleson on 9/29/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Foundation
import UIKit
import Pulley
import MapKit

class HouseListController: UIViewController, UITableViewDataSource, UITableViewDelegate, HouseManagerUpdateDelegate, PulleyDrawerViewControllerDelegate {
    public var houses: [HouseModel] = []
    private var houseManager = HouseManager()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var gripperView: UIView!
    @IBOutlet var gripperTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        houseManager.updateDelegate = self
        gripperView.layer.cornerRadius = 2.5
    }

    override func viewDidAppear(_ animated: Bool) {
        if let drawer = self.parent as? PulleyViewController {
            drawer.delegate = self
            drawer.setDrawerPosition(position: .partiallyRevealed, animated: true)
            drawer.setNeedsSupportedDrawerPositionsUpdate()
        }
    }

    // This function is called when the current drawer display mode changes. Make UI customizations here.
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        print("Drawer: \(drawer.currentDisplayMode)")
        gripperTopConstraint.isActive = (drawer.currentDisplayMode == .bottomDrawer)
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed,
                .partiallyRevealed]
    }

    func update(houses: [HouseModel]) {
        self.houses = houses
        self.tableView.reloadData()
    }

    func locationWasUpdated() {
        var indexPathsNeedToReload = [IndexPath]()

        for cell in tableView.visibleCells {
            let indexPath: IndexPath = tableView.indexPath(for: cell)!

            if indexPath.section == 0 {
                indexPathsNeedToReload.append(indexPath)
            }
        }
        print("m'fukn updated")
        tableView.reloadRows(at: indexPathsNeedToReload, with: .automatic)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let drawer = self.parent as? PulleyViewController
            {
            let drawerContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "infoCard")
            (drawerContent as! InfoCardController).house = houses[indexPath.row]
            (drawerContent as! InfoCardController).currentUID = self.houseManager.userId
            drawer.setDrawerContentViewController(controller: drawerContent, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return houses.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "houseCell")
        let house = houses[indexPath.row]


        if(houseManager.userOwnsHouse(house: house)) {
            cell?.textLabel?.text = "Your house"
        } else {
            cell?.textLabel?.text = house.name!
        }

        let location = CLLocation(latitude: (house.location?.latitude)!, longitude: (house.location?.longitude)!)
        if(houseManager.currentUserLocation != nil) {
            let distance = ((houseManager.currentUserLocation?.distance(from: location))!) / 1609.344
            cell?.detailTextLabel?.text = "\(distance.rounded(toPlaces: 2)) miles"
        } else {
            cell?.detailTextLabel?.text = "uhh"
        }

        return cell!
    }
}

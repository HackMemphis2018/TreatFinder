//
//  InfoCardController.swift
//  TreatFinder
//
//  Created by Keaton Burleson on 9/29/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Foundation
import UIKit
import Pulley
import Cosmos

class InfoCardController: UIViewController, PulleyDelegate{
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var averageRating: CosmosView?
    @IBOutlet weak var reviewButton: UIButton?
    
    var house: HouseModel? = nil
    var currentUID: String? = nil
    var savedRatingView: CosmosView? = nil
    
    private var houseManager = HouseManager()
    
    override func viewDidLoad() {
        if let drawer = self.parent as? PulleyViewController{
            drawer.delegate = self
            drawer.setDrawerPosition(position: .partiallyRevealed, animated: true)
            drawer.setNeedsSupportedDrawerPositionsUpdate()
        }
        
        guard let house = house
            else{
                return
        }
        
        averageRating?.rating = house.averageRating()
        nameLabel?.text = house.name!
        
        configureButton()
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed,
                .partiallyRevealed,
                .closed]
    }
    
    @IBAction func showRatingAlert(){
        let alert = UIAlertController(title: "\n\n", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: alert.view.frame.width, height: 50))
        
        //The x/y coordinate of the rating view
        let xCoord = alert.view.frame.width/2 - 95 //(5 starts multiplied by 30 each, plus a 5 margin each / 2)
        let yCoord = CGFloat(25.0)
        
        let ratingView = CosmosView(frame: CGRect(x: xCoord, y: yCoord, width: 300, height: 50))
        ratingView.rating = 0.0
        ratingView.settings.starSize = 30
        ratingView.settings.emptyBorderColor = .black
        ratingView.settings.updateOnTouch = true
        savedRatingView = ratingView
        
        customView.addSubview(ratingView)
        
        alert.addAction(UIAlertAction(title: "Submit Rating", style: .default, handler: { (action) in
            self.ratingCompletionHandler(rating: ratingView.rating)
            self.configureButton(disable: true)
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.view.addSubview(customView)
        
        self.show(alert, sender: self)
    }
    
    func ratingCompletionHandler(rating: Double){
        houseManager.updateRating(house: self.house!, rating: rating)
    }
    
    func configureButton(disable: Bool = false){
        if(house?.canReview(userID: self.currentUID) == true && !disable){
            reviewButton?.isEnabled = true
            reviewButton?.titleLabel?.text = "Submit Review"
            reviewButton?.backgroundColor = reviewButton?.tintColor
        }else{
            reviewButton?.isEnabled = false
            reviewButton?.setTitle("Already Reviewed", for: .disabled)
            reviewButton?.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func dismissCard(){
        if let drawer = self.parent as? PulleyViewController
        {
            let drawerContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "houseList")
            drawer.setDrawerContentViewController(controller: drawerContent, animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

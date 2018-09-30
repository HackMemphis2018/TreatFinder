//
//  KABRoundButton.swift
//  TreatFinder
//
//  Created by Keaton Burleson on 9/29/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Foundation
import UIKit

class KABRoundButton: UIButton{
    override init(frame: CGRect) {
        let absFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.width)
        super.init(frame: absFrame)
        configureLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLayer()
    }
    
    func configureLayer(){
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
}

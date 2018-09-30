//
//  HouseModel.swift
//  TreatFinder
//
//  Created by Keaton Burleson on 9/29/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Foundation

struct HouseModel: Codable {
    var location: HousePoint?
    var ratings: [Double] = []
    var submittedRatings: [String] = []
    var name: String?
    var userID: String
    var documentID: String?

    init(userID: String) {
        self.userID = userID
    }

    func averageRating() -> Double {
        var total = 0.0

        for rating in self.ratings {
            total += Double(rating)
        }

        let votesTotal = Double(self.ratings.count)

        if(votesTotal == 0.0 || total == 0.0) {
            return 0.0
        }

        return total / votesTotal
    }

    func canReview(userID: String?) -> Bool {
        if(userID != nil) {
            return !submittedRatings.contains(NSUUID().uuidString.lowercased()) && self.userID != userID
        } else {
            return !submittedRatings.contains(NSUUID().uuidString.lowercased())
        }
    }
}

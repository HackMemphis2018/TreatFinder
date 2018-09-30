//
//  HousePoint.swift
//  TreatFinder
//
//  Created by Keaton Burleson on 9/29/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import FirebaseFirestore

final class HousePoint: GeoPoint, Codable
{
    override init(latitude: Double, longitude: Double)
    {
        super.init(latitude: latitude, longitude: longitude)
    }

    private enum CodingKeys: String, CodingKey
    {
        case latitude = "_latitude"
        case longitude = "_longitude"
    }

    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var lat: Double = 0
        var lon: Double = 0

        do
        {
            lat = try container.decode(Double.self, forKey: .latitude)
        }
        catch
        {
            print("no latitude for HousePoint")
        }

        do
        {
            lon = try container.decode(Double.self, forKey: .longitude)
        }
        catch
        {
            print("no longitude for HousePoint")
        }


        super.init(latitude: lat, longitude: lon)
    }

    public func getCoordinate() -> CLLocationCoordinate2D {
        let coord = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        return coord
    }

    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

}

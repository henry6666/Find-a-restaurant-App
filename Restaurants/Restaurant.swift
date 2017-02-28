//
//  Restaurant.swift
//  Restaurants
//
//  Created by Henry Aguinaga on 2017-02-26.
//  Copyright © 2017 Henry Aguinaga. All rights reserved.
//

import UIKit

class Restaurant: NSObject {
    
    var name: String?
    var lat: Double?
    var lng: Double?
    var address: String?
    var open: Bool?
    var rating: Int?
    var priceLavel: Int?
    var webUrl: URL?
    
    
    init(name: String, latitude: Double, longitude: Double, address: String, open: Bool, rating: Int, priceLavel: Int) {
        
        self.name = name
        self.lat = latitude
        self.lng = longitude
        self.address = address
        self.open = open
        self.rating = rating
        self.priceLavel = priceLavel
        self.webUrl = URL(string: "")
    }
    

}

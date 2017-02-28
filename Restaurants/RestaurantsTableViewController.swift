//
//  RestaurantsTableViewController.swift
//  Restaurants
//
//  Created by Henry Aguinaga on 2017-02-26.
//  Copyright © 2017 Henry Aguinaga. All rights reserved.
//

import UIKit
import MapKit

class RestaurantsTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    //37.788943, -122.407190
    
    let identifier = "restaurantsCell"
    var url: String?
    var userLocation: CLLocation?
    var distanceKm: String?

    var restaurants: [Restaurant] = [Restaurant]()
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        addGeoLocation()
        
        
    }
    
    func addGeoLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        userLocation = location
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        
        url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lng)&radius=2000&type=restaurant&keyword=cruise&key=PUT YOUR OWN KEY HERE"
        
        downloadRestaurants(url!) { (array) in
            self.restaurants = array
            self.tableView.reloadData()
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        let restaurant = restaurants[indexPath.row]
        
        
        cell.textLabel?.text = restaurant.name!
        
        if restaurant.priceLavel! == 6 {
            cell.detailTextLabel?.text = ""
        }
        
        //cell.detailTextLabel?.text = displayPriceLevel(price: restaurant.priceLavel!)
        
        distanceKm = calculateDistanceKM(restaurant.lat!, restaurant.lng!) + " Km"
        cell.detailTextLabel?.text = calculateDistanceKM(restaurant.lat!, restaurant.lng!) + " Km"

        return cell
    }
 
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "goToDetails" {
            let viewVC = segue.destination as! ViewController
            let indexPath = tableView.indexPathForSelectedRow
            let index = indexPath?.row
            let restaurantSelected = restaurants[index!]
            
            viewVC.restaurant = restaurantSelected
            viewVC.distanceKm = distanceKm
            
        }
        
    }
}

extension RestaurantsTableViewController {
    
    func downloadRestaurants(_ urlStr:String, completion: @escaping (_ array:[Restaurant]) ->()) {
        
        var arrayRestaurants:[Restaurant] = [Restaurant]()
        var openNow:Bool = false
        
        let url = URL(string: urlStr)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error == nil {
                if let dataValid = data {
                    
                    do {
                        let jsonDict = try JSONSerialization.jsonObject(with: dataValid, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        //print(jsonDict)
                        let list = jsonDict["results"] as! NSArray
                        
                        for restaurant in list {
                            
                            let aRestaurant = restaurant as! NSDictionary
                            
                            let geo = aRestaurant["geometry"] as! NSDictionary
                            let loc = geo["location"] as! NSDictionary
                            let lat = loc["lat"] as! Double
                            let lng = loc["lng"] as! Double
                            
                            if let openingHours = aRestaurant["opening_hours"] as? NSDictionary {
                                openNow = openingHours["open_now"] as! Bool
                            }
  
                            let name = aRestaurant["name"] as! String
                            
                            let address = aRestaurant["vicinity"] as! String
                            
                            let rating = aRestaurant["rating"] as? Int ?? 0
                            let price_level = aRestaurant["price_level"] as? Int ?? 6
                            
                            let newRestaurants = Restaurant(name: name, latitude: lat, longitude: lng, address: address, open: openNow, rating: rating, priceLavel: price_level)
                            
                            arrayRestaurants.append(newRestaurants)
                            
                            DispatchQueue.main.async(execute: { 
                                completion(arrayRestaurants)
                            })
                            
                            
                        }

                    } catch {
                    
                        print(error.localizedDescription)
                    } // do
                } // if
            } // if
        } // task
        
        task.resume()
    }
    
    func calculateDistanceKM(_ lat: Double, _ lng: Double) -> String {
        
        var distanceLocationStr: String?
        var distance: CLLocationDistance
        let restaurantLocation = CLLocation(latitude: lat, longitude: lng)
        distance = (userLocation?.distance(from: restaurantLocation))!
        
        let distanceKM = NSString(format: "%.2f", distance / 1000)
        
        distanceLocationStr = String(distanceKM)
        
        return distanceLocationStr!
    }
    
    func displayPriceLevel(price:Int) -> String {
        
        var priceLevelStr: String?
        
        switch price {
            case 0:
                priceLevelStr = "free"
                
            case 1:
                priceLevelStr = "$"
                
            case 2:
                priceLevelStr = "$$"
                
            case 3:
                priceLevelStr = "$$$"
                
            case 4:
                priceLevelStr = "$$$$"
            default:
                priceLevelStr = ""
            }
        
       return priceLevelStr!
    }
}









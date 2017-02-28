//
//  ViewController.swift
//  Restaurants
//
//  Created by Henry Aguinaga on 2017-02-26.
//  Copyright © 2017 Henry Aguinaga. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    
    var locationManager: CLLocationManager = CLLocationManager()
    var restaurant: Restaurant?
    var distanceKm: String?
    var userLocation: CLLocation?



    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = restaurant?.name
        
        addMap()
        displayDetails()
        addGeoLocation()
    }
    
    func addGeoLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        map.showsUserLocation = true
    }
    
    func addMap() {
        let lat = restaurant?.lat!
        let lng = restaurant?.lng!
        
        // Map
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, lng!)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region, animated: true)
        
        // Annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = restaurant?.name
        annotation.subtitle = restaurant?.address
        
        map.addAnnotation(annotation)
        
    }
    
    func displayDetails() {
        nameLabel.text = restaurant?.name
        distanceLabel.text = distanceKm
        displayOpenLabel(open: (restaurant?.open!)!)
        ratingLabel.text = displayRatingStars(rating: (restaurant?.rating!)!)
    }
    
    func displayOpenLabel(open: Bool) {
        
        if open {
            openLabel.text = "Open"
            openLabel.textColor = UIColor.green
        } else {
            openLabel.text = "Closed"
            openLabel.textColor = UIColor.red
        }
    }
    
    func displayRatingStars(rating: Int) -> String{
        var ratingStars: String?
        
        switch rating {
            case 0:
                ratingStars = ""
            case 1:
                ratingStars = "⭐️"
            case 2:
                ratingStars = "⭐️⭐️"
            case 3:
                ratingStars = "⭐️⭐️⭐️"
            case 4:
                ratingStars = "⭐️⭐️⭐️⭐️"
            case 5:
                ratingStars = "⭐️⭐️⭐️⭐️⭐️"
            default:
                ratingStars = ""
        }
        return ratingStars!
    }

}

extension ViewController: MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userLocation = locations.first
        displayRoutes()
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func displayRoutes()  {
        
        if userLocation != nil {
            
            // locations
            let sourceLocation = CLLocation(latitude: (userLocation?.coordinate.latitude)!, longitude: (userLocation?.coordinate.longitude)!)
            
            let destLocation = CLLocation(latitude: (restaurant?.lat)!, longitude: (restaurant?.lng)!)
            
            // Placemarks
            
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation.coordinate, addressDictionary: nil)
            
            let destinationPlacemark = MKPlacemark(coordinate: destLocation.coordinate, addressDictionary: nil)
            
            // region
            
            let region = MKCoordinateRegionMakeWithDistance(sourceLocation.coordinate, 15000, 15000)
            
            map.delegate = self
            
            // request
            
            let request = MKDirectionsRequest()
            request.source = MKMapItem(placemark: sourcePlacemark)
            request.destination = MKMapItem(placemark: destinationPlacemark)
            request.requestsAlternateRoutes = false
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate(completionHandler: { (response, error) in
                
                if error == nil {
                    for route in (response!.routes) {
                        
                        self.map.add(route.polyline)
                        
                        
                    } // for
                } else {
                    print("Error displaying routes information")
                    print(error?.localizedDescription)
                }
                
            })
            
            
        }
    }
    
}








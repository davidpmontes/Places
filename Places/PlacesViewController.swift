//
//  ViewController.swift
//  Places
//
//  Created by David Montes on 1/11/20.
//  Copyright © 2020 David Montes. All rights reserved.
//

import UIKit
import MapKit

class PlacesViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var mapView:MKMapView?
    @IBOutlet var tableView:UITableView?
    
    var locationManager:CLLocationManager?
    
    var places = [[String: Any]]()
    
    var isQueryPending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        
        locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager!.distanceFilter = 50.0
        
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard mapView != nil else {
            return
        }
        
        guard let newLocation = locations.last else {
            return
        }
        
        let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        let adjustedRegion = mapView!.regionThatFits(region)
        
        mapView!.setRegion(adjustedRegion, animated: true)
        
        queryFoursquare(location: newLocation)
    }
    
    func queryFoursquare(location: CLLocation)
    {
        if isQueryPending == true {
            return
        }
        
        isQueryPending = true
        
        let clientId        = URLQueryItem(name: "client_id", value: FourSquareAPI().ClientID)
        let clientSecret    = URLQueryItem(name: "client_secret", value: FourSquareAPI().ClientSecret)
        let version         = URLQueryItem(name: "v", value: "20190401")
        let coordinate      = URLQueryItem(name: "ll", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
        let query           = URLQueryItem(name: "query", value: "coffee")
        let intent          = URLQueryItem(name: "intent", value: "browse")
        let radius          = URLQueryItem(name: "radius", value: "250")
        
        var urlComponents = URLComponents(string: "https://api.foursquare.com/v2/venues/search")!
        urlComponents.queryItems = [clientId, clientSecret, version, coordinate, query, intent, radius]

        let task = URLSession.shared.dataTask(with: urlComponents.url!, completionHandler: { data, response, error in
            if error != nil {
                print("*** ERROR *** \(error!.localizedDescription)")
                return
            }
            
            if data == nil || response == nil {
                print("*** SOMETHING WENT WRONG!!! ***")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: [])

                print(jsonData)

            } catch {
                print("*** JSON ERROR *** \(error.localizedDescription)")
                return
            }
            
            self.isQueryPending = false
        })

        task.resume()
    }
}


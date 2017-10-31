//
//  MapViewController.swift
//  cAir
//
//  Created by Taco on 8/4/16.
//  Copyright © 2016 Taco. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitude: UILabel!
    
    @IBAction func seeAllSamples(_ sender: AnyObject) {
        ViewController().updateMethod("all")
    }
    
    @IBAction func sampleRegion(_ sender: AnyObject) {
        
        let reg = mapView.region
        let center: CLLocationCoordinate2D = reg.center
        var northWestCorner: CLLocationCoordinate2D = center
        var southEastCorner: CLLocationCoordinate2D = center
        
        northWestCorner.latitude = center.latitude - (reg.span.latitudeDelta / 2.0)
        northWestCorner.longitude = center.longitude - (reg.span.longitudeDelta / 2.0)
        
        southEastCorner.latitude = center.latitude + (reg.span.latitudeDelta / 2.0)
        southEastCorner.longitude = center.longitude + (reg.span.latitudeDelta / 2.0)
        
        //make sure there's nothing in these arrays
        locat.possibleLatRegion = []
        locat.possibleLngRegion = []
        
        
        for i in 0 ..< locat.possibleLat.count{
            let locationLat = Double(locat.possibleLat[i])
            let locationLng = Double(locat.possibleLng[i])
            
            if(locationLat >= northWestCorner.latitude && locationLat <= southEastCorner.latitude && locationLng >= northWestCorner.longitude && locationLng <= southEastCorner.longitude){
                
                // put in the table for sample region
                locat.possibleLatRegion.append(locat.possibleLat[i])
                locat.possibleLngRegion.append(locat.possibleLng[i])
                
                
                
            }
        }
        
        ViewController().updateTable(locat.possibleLatRegion, longitudes: locat.possibleLngRegion)
        
        print(locat.possibleLatRegion)
        print(locat.possibleLngRegion)
        
    }
    
    
    
    struct locat{
        static var lat = " "
        static var lng = " "
        static var possibleLat: [String] = []
        static var possibleLng: [String] = []
        
        
        static var possibleLatRegion: [String] = []
        static var possibleLngRegion: [String] = []
        
        
    }
    
    
    func getPossibleLat() -> [String]{
        return locat.possibleLat
    }
    
    func getPossibleLng() -> [String]{
        return locat.possibleLng
    }
    
    func getPossibleLatRegion() -> [String]{
        return locat.possibleLatRegion
    }
    
    func getPossibleLngRegion() -> [String]{
        return locat.possibleLngRegion
    }
    
    

    
    func addPossibleLat(_ addition: String){
        locat.possibleLat.append(addition)
    }
    
    func addPossibleLng(_ addition: String){
        locat.possibleLng.append(addition)
    }
    
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
       
    }
    
    func giveLocation(_ la: String, lo: String){
        locat.lat = la
        locat.lng = lo
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    fileprivate let regionRadius: CLLocationDistance = 400
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Artwork {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                //view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let userLocation:CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        let loc = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        locat.lat = String(userLocation.coordinate.latitude)
        locat.lng = String(userLocation.coordinate.longitude)
        
        latitude.text = "Latitude: " + locat.lat + "    Longitude: " + locat.lng
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(loc.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        
        for i in 0 ..< locat.possibleLat.count{
            let artwork = Artwork(title: "",
                                  locationName: "",
                                  discipline: "Sample",
                                  coordinate: CLLocationCoordinate2D(latitude: Double(locat.possibleLat[i])!, longitude: Double(locat.possibleLng[i])!))
            
            mapView.addAnnotation(artwork)
        }
        
        
        mapView.showsUserLocation = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: " + error.localizedDescription)
    }
    
}



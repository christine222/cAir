//
//  ViewController2.swift
//  cAir
//
//  Created by Taco on 7/28/16.
//  Copyright © 2016 Taco. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController2: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
  
    struct locat{
        static var lat = "34.2523" //placeholder so that there's no nil error
        static var lng = "-122.4252"
    }

    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        let artwork = Artwork(title: "",
                              locationName: "",
                              discipline: "Sample",
                              coordinate: CLLocationCoordinate2D(latitude: Double(locat.lat)!, longitude: Double(locat.lng)!))
        
        mapView.addAnnotation(artwork)
        
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
    
    
    fileprivate let regionRadius: CLLocationDistance = 1000

    
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
        //let userLocation:CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        
        //let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        //let loc = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let loc = CLLocation(latitude: Double(locat.lat)! , longitude: Double(locat.lng)!)
        

        //print(location.latitude)

        //print(location.longitude)
        
        
        //latitude.text = "Latitude: " + String(format: "%.4f", location.latitude) + "    Longitude: " + String(format: "%.4f", location.longitude)
        
        latitude.text = "Latitude: " + locat.lat + "    Longitude: " + locat.lng
        
        //locat.lat = String(format: "%.4f", location.latitude)
        //locat.lng = String(format: "%.4f", location.longitude)
        
        //print("in location: " + locat.lat + ", " + locat.lng)
        
    
       
        
        //let span = MKCoordinateSpanMake(0.005, 0.005)
        
        //let region = MKCoordinateRegion (center:  location, span: span)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(loc.coordinate,
                                                                 regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        //mapView.setRegion(region, animated: true)
        //mapView.setCenterCoordinate(location, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: " + error.localizedDescription)
    }

}

//
//  ViewController.swift
//  cAir
//
//  Created by Taco on 7/21/16.
//  Copyright © 2016 Taco. All rights reserved.
//

import UIKit
import CoreGraphics
import MapKit

import CoreLocation



class TableViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var actualTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    struct dataSampleRegion{
        static var graphData = [] as NSArray
        static var histData: [[Double]] = []
        static var numberSamples = 1 //number of total samples (table view needs to know this value)
        static var deviceNames: [String] = ["SDf","SDf"]
        static var dates: [String] = ["Jun", "jell"]
        static var times: [String] = ["sdf","sdfa"]
        static var longitude: [String] = []
        static var latitude: [String] = []
        static var result: [String] = []
    }
    
    
    
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        
        
        return 2
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CustomCellRegion", for: indexPath) as! CustomCell
        
        
        dataSampleRegion.latitude = MapViewController().getPossibleLatRegion()
        dataSampleRegion.longitude = MapViewController().getPossibleLngRegion()
        
        print(dataSampleRegion.latitude)
        print(dataSampleRegion.longitude)
        
        
        cell.sampleLabel.text = dataSampleRegion.deviceNames[indexPath.row]
        cell.sampleDate.text = dataSampleRegion.dates[indexPath.row]
        cell.sampleTime.text = dataSampleRegion.times[indexPath.row]
        
        //print(dataSamples.graphData.count)
        
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "swipeInfo", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "rootSwipe") as UIViewController
        //self.presentViewController(nextViewController, animated:true, completion:nil)
        self.navigationController!.pushViewController(nextViewController, animated: true)
        
        GraphView().giveGraphData(dataSampleRegion.histData[indexPath.row])
        ViewController2().giveLocation(dataSampleRegion.latitude[indexPath.row], lo: dataSampleRegion.longitude[indexPath.row])
        let datetime = dataSampleRegion.dates[indexPath.row] + " " +  dataSampleRegion.times[indexPath.row]
        
        SwipeViewController().giveInfo(dataSampleRegion.deviceNames[indexPath.row], date: datetime)
        
        let part: String = dataSampleRegion.result[indexPath.row]
        ViewController0().giveParticle(part)
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

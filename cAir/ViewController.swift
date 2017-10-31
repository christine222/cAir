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
import Foundation


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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}






class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate{
    
    //Ozrouter
    //var HOST = "http://192.168.1.137:2934"
    
    //var HOST = "169.254.233.3:2934"
    var HOST = "http://172.20.10.8:2935" // yichens phone
    
    //var HOST = "http://172.20.10.4:2934"
    //var HOST = "http://192.168.43.39:2934" // christine samsung s5 phone
    //var HOST = "http://172.20.10.3:2934" // hatice iphone
    //var HOST = "http://192.168.1.137:2935"
    
    

    struct dataSamples{
       
        static var graphData = [] as NSArray
        static var histData: [[Double]] = []
        static var numberSamples = 0 //number of total samples (table view needs to know this value)
        static var deviceNames: [String] = []
        static var dates: [String] = []
        static var times: [String] = []
        static var longitude: [String] = []
        static var latitude: [String] = []
        static var result: [String] = []
        static var method = "all"
        static var regionIndexes: [Int] = [] //specifies which index the samples are for a given region
    }
    
    
    struct calibration{
        static var sampleId = "2016-09-30_16-49-07"
        static var deviceId = "Red32_Dot"//raspi.deviceName
    }
    
    func updateMethod(_ method: String){
        
        if method == "all"{
            dataSamples.method = "all"
        }
    }
    
    
    //Loading Bar
    /*var indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = view.center
    view.addSubview(indicator)
    indicator.bringSubviewToFront(view)
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
 */



    
    //TABLE STUFF
        @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBAction func refreshTable(_ sender: AnyObject) {
        
        let requestURL: URL = URL(string: "http://tcmaucla.ee.ucla.edu/all_samples.json")!
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                do{
                    print("json received successfully!")
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    self.readData(json as! NSArray)
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }) 
        task.resume()
        self.tableView.reloadData()
    }
    
    
    func updateTable(_ latitudes: [String], longitudes: [String]){
        
        
        
        
        let currentLat = dataSamples.latitude
        let currentLng = dataSamples.longitude
        dataSamples.method = "region"
        dataSamples.regionIndexes = []
        
        print(dataSamples.latitude.count)
        
        for i in 0 ..< dataSamples.latitude.count{
            
            for j in 0 ..< latitudes.count{
                
                if (currentLat[i] == latitudes[j] && currentLng[i] == longitudes[j]){
                    
                    
                    dataSamples.regionIndexes.append(i) //if the index matches then put the index into array
                
                }
            }
        }
        
        print("printing region indexes")
        print(dataSamples.regionIndexes)
        
    }


    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        
        var num = 0
        
        if (dataSamples.method == "all"){
            num = dataSamples.numberSamples
        }else{
            num = dataSamples.regionIndexes.count
        }
        
        return num
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        if (dataSamples.method == "all"){
            cell.sampleLabel.text = dataSamples.deviceNames[indexPath.row]
            cell.sampleDate.text = dataSamples.dates[indexPath.row]
            cell.sampleTime.text = dataSamples.times[indexPath.row]
            
        }else if(dataSamples.method == "region"){
            
            let index = dataSamples.regionIndexes[indexPath.row]
            cell.sampleLabel.text = dataSamples.deviceNames[index]
            cell.sampleDate.text = dataSamples.dates[index]
            cell.sampleTime.text = dataSamples.times[index]
        }
        
        
        
        
        
        //print(dataSamples.graphData.count)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "swipeInfo", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "rootSwipe") as UIViewController
        //self.presentViewController(nextViewController, animated:true, completion:nil)
        self.navigationController!.pushViewController(nextViewController, animated: true)
        
        if (dataSamples.method == "all"){
            
            GraphView().giveGraphData(dataSamples.histData[indexPath.row])
            ViewController2().giveLocation(dataSamples.latitude[indexPath.row], lo: dataSamples.longitude[indexPath.row])
            let datetime = dataSamples.dates[indexPath.row] + " " +  dataSamples.times[indexPath.row]
            SwipeViewController().giveInfo(dataSamples.deviceNames[indexPath.row], date: datetime)
            
            let part: String = dataSamples.result[indexPath.row]
            ViewController0().giveParticle(part)
            
        }else if(dataSamples.method == "region"){
            
            print(indexPath.row)
            print(dataSamples.regionIndexes)
            
            let index = dataSamples.regionIndexes[indexPath.row]
            
            print("index:")
            print(index)
            print("indexPath.row")
            print(indexPath.row)
            
            GraphView().giveGraphData(dataSamples.histData[index])
            ViewController2().giveLocation(dataSamples.latitude[index], lo: dataSamples.longitude[index])
            let datetime = dataSamples.dates[index] + " " +  dataSamples.times[index]
            SwipeViewController().giveInfo(dataSamples.deviceNames[index], date: datetime)
            
            let part: String = dataSamples.result[index]
            ViewController0().giveParticle(part)
            
        }
        
        
        
        
    }
    
    
    func readData(_ data: NSArray){
        dataSamples.graphData = data as NSArray
        dataSamples.numberSamples = data.count
        //print(dataSamples.graphData.count)
        
        dataSamples.graphData = []
        dataSamples.histData = []
        dataSamples.deviceNames = []
        dataSamples.dates = []
        dataSamples.times = []
        dataSamples.longitude = []
        dataSamples.latitude = []
        dataSamples.result = []
        
        
        
        
        for i in 0 ..< data.count  {
            
            let currentSample = data[i] as! NSDictionary
            let device = currentSample["deviceId"] as? String
            
            
            
            //add device name to deviceNames array
            dataSamples.deviceNames.append(device!)
            let sampleId = currentSample["sampleId"] as? String
            

            
            
            let dateRange = (sampleId!.characters.index(sampleId!.startIndex, offsetBy: 0) ..< sampleId!.characters.index(sampleId!.startIndex, offsetBy: 10))
            let date = sampleId!.substring(with: dateRange)

            
            //let timeRange = (sampleId!.characters.index(sampleId!.startIndex, offsetBy: 11) ..< sampleId!.characters.index(sampleId!.startIndex, offsetBy: 17))
            //let time = sampleId!.substring(with: timeRange)
            let time = "14:32:33"
            
            //add time to times array and date to dates array
            dataSamples.times.append(prettyTime(time))
            dataSamples.dates.append(prettyDate(date))
            
            let histogramData = processHist((currentSample["hist_data"] as? String)!)
            dataSamples.histData.append(histogramData)
            
            let lat = currentSample["latitude"] as? String
            dataSamples.latitude.append(lat!)
            let lng = currentSample["longitude"] as? String
            dataSamples.longitude.append(lng!)
            
            let r = currentSample["result"] as? String
            dataSamples.result.append(r!)
            
            let possibleLat = MapViewController().getPossibleLat()
            let possibleLng = MapViewController().getPossibleLng()
            var l = 0
            
            for j in 0 ..< possibleLat.count{
                if (lat == possibleLat[j]) && (lng == possibleLng[j]) {
                    l += 1
                }
            }
            
            if l == 0{
                MapViewController().addPossibleLat(lat!)
                MapViewController().addPossibleLng(lng!)
            }
        }
    }
    
    //turn ugly string of "2.32, 124.3, 252.32, etc..." to [3, 45, 1, 45, ....] for graphView class
    func processHist(_ data: String) -> [Double]{
        
        if data == ""{
            return [0]
        }
        
        var histogram: [Double] = []
        var compare: [Float] = []
        var trueDataString: [String] = []
        trueDataString = data.components(separatedBy: ",") //convert string to string array
        let trueData = trueDataString.map { Float($0)!} //convert string arrary to float array
        
        
        for i in 0 ..< 45{
            if ((i%2) == 0) && (i != 0){
                histogram.append(0) //creates [0, 0, 0, 0, 0, 0, 0, ... 0]
                compare.append(Float(i)) //creates [2, 4, 6, 8, 10, ... 42]
            }
        }
        
        for i in 0 ..< trueData.count{
            
            for j in 0 ..< compare.count{
                
                if (j != 0) {
                
                    if (trueData[i] < compare[j]) && (trueData[i] > compare[j - 1]){
                        histogram[j] += 1
                        break
                    }

                }else{
                    if (trueData[i] < compare[j]){
                        histogram[j] += 1
                        break
                    }
                }
                
                
            }
        }
        
        for i in 0 ..< histogram.count{
            histogram[i] *= 15/1.4/6.5
        }
    
        return histogram
    }
    
    
    //takes a date string in the format 2016-02-01 (YEAR-MONTH-DAY) and prints out Feb 1, 2016
    func prettyDate(_ date: String) -> String{
        var pretty = ""
        
        //add correct month
        var dateRange = (date.characters.index(date.startIndex, offsetBy: 5) ..< date.characters.index(date.startIndex, offsetBy: 7))
        let month = date.substring(with: dateRange)
        
        let months: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "November", "December"]
        let monthNum: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        
        for i in 0 ..< monthNum.count  {
            if month == monthNum[i]{
                pretty += months[i]
            }
        }
        
        //add day
        dateRange = (date.characters.index(date.startIndex, offsetBy: 8) ..< date.characters.index(date.startIndex, offsetBy: 10))
        let day = date.substring(with: dateRange)
        pretty += " " + day
        
        //add year
        dateRange = (date.characters.index(date.startIndex, offsetBy: 0) ..< date.characters.index(date.startIndex, offsetBy: 4))
        let time = date.substring(with: dateRange)
        pretty += ", " + time
        
        return pretty
    }
    
    
    //takes a time string in the format 13-30-20 (HOUR_MIN_SEC) and prints 1:30 PM
    func prettyTime(_ date: String) -> String{
        var pretty = " "
        var period = "AM"
        
        //hour
        var timeRange = (date.characters.index(date.startIndex, offsetBy: 0) ..< date.characters.index(date.startIndex, offsetBy: 2))
        var hour = Int(date.substring(with: timeRange))
        
        if hour > 12{
            hour = hour! - 12
            period = "PM"
        }
        
        pretty += String(hour!)
        
        //minute
        timeRange = (date.characters.index(date.startIndex, offsetBy: 3) ..< date.characters.index(date.startIndex, offsetBy: 5))
        let minute = date.substring(with: timeRange)
        
        //seconds
        timeRange = (date.characters.index(date.startIndex, offsetBy: 6) ..< date.characters.index(date.startIndex, offsetBy: 8))
        let seconds = date.substring(with: timeRange)
        
        
        pretty += ":" + minute + ":" + seconds + " " + period

        return pretty
    }
    
    
 
 
    
    
    
    
    
    
    //Kevin's iPhone http://172.20.10.3:2935
    
    
    let locationManager = CLLocationManager()
    
    //let place: [String] = [ViewController2.locat.lat, ViewController2.locat.lng]
    
    @IBOutlet weak var textField: UITextField!
    
    struct locat{
        static var lat = " "
        static var lng = " "
    }
    
    //for the exchange info page
 
    
    // notifies user that location was not taken (on the camera screen)
    @IBOutlet weak var connectionProblem: UILabel!
    
    
    
    func makeJSONRequest(){
        let requestURL: URL = URL(string: "http://tcmaucla.ee.ucla.edu/all_samples.json")!
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                do{
                    
                    //print("json received successfully!")
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    self.readData(json as! NSArray)
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
            }
        }) 
        
        task.resume()
    }
    
    
    @IBAction func viewData(_ sender: AnyObject) {
        //reading json file with all the past conducted samples
        makeJSONRequest()
    }
    
    
    
    
   
    @IBAction func measureAirQuality(_ sender: AnyObject) {
        
        
    }
    

    @IBAction func calibrateDevice(_ sender: AnyObject) {
       /*
        let storyBoard : UIStoryboard = UIStoryboard(name: "swipeInfo", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("rootSwipe") as UIViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
 */
        
        
        if(raspi.deviceName == " "){
            //do nothing
            print("device is not connected")
            self.deviceName?.text = "A device is not connected."
            
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "getCalibInfo") as UIViewController
            
            //self.presentViewController(nextViewController, animated:true, completion:nil)
            self.navigationController!.pushViewController(nextViewController, animated: true)
            

        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "getCalibInfo") as UIViewController
            
            //self.presentViewController(nextViewController, animated:true, completion:nil)
            self.navigationController!.pushViewController(nextViewController, animated: true)
            
            
            let todaysDate:Date = Date()
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let DateInFormat:String = dateFormatter.string(from: todaysDate)
            calibration.sampleId = DateInFormat
            
            let UDIDaddr = UIDevice.current.identifierForVendor!.uuidString
            
            let parameters = ["HWaddr": UDIDaddr, "IPaddr": "198.168.1.116", "latitude": locat.lat, "longitude" : locat.lng, "method" : "calibration", "sampleId" : DateInFormat] as Dictionary<String, String>
            
            
            let url = URL(string: HOST)
            let session = URLSession.shared
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error in guard data != nil else {
                print("no data found: \(error)")
                return
                }
                
                do{
                    if let responseData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String{
                        print(responseData)
                    }else{
                        let responseStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print("Error bad response: \(responseStr)")
                    }
                }catch let parseError {
                    print(parseError)
                    let responseStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse string: \(responseStr)'")
                }
                
                
            }) 
            
            task.resume()
        }
    }
    @IBAction func turnOff(_ sender: UIButton) {
        
        print ("turning off")
        
        
        
        if(raspi.hwaddr != " "){
            
            let UDIDaddr = UIDevice.current.identifierForVendor!.uuidString
            let parameters = ["HWaddr": UDIDaddr, "IPaddr": "198.168.1.116", "latitude": locat.lat, "longitude" : locat.lng, "method" : "poweroff"] as Dictionary<String, String>
            
            
            let url = URL(string: HOST)
            let session = URLSession.shared
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error in guard data != nil else {
                print("no data found: \(error)")
                return
                }
                
                do{
                    if let responseData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String{
                        print(responseData)
                    }else{
                        let responseStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print("Error bad response: \(responseStr)")
                    }
                }catch let parseError {
                    print(parseError)
                    let responseStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse string: \(responseStr)'")
                }
                
                
            })
            
            task.resume()
            
            self.infoLabel?.text = "Did not work, check host and try again."
        }else{
            self.infoLabel?.text = "Powering Off"
        }
        

        
    }

    
    @IBAction func getCalibrationInfo(_ sender: AnyObject) {
        
        /*
        let requestURL: NSURL = NSURL(string: "http://tcmaucla.ee.ucla.edu/calibrations/Red32_Dot/2016-09-30_16-49-07/calibData.json")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                do{
                    
                    //print("json received successfully!")
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    self.readData(json as! NSArray)
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
            }
        }
        
        task.resume()
 
 */

    }
    
    var data: String = "{\"graphPointsY\": [706, 468, 41, 255, 574, 85, 223, 1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], \"graphPointsX\": [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41]}"
 
    
    
    @IBOutlet weak var graphHigh: UILabel!
    @IBOutlet weak var graphHighMed: UILabel!
    @IBOutlet weak var graphLowMed: UILabel!
    @IBOutlet weak var graphLow: UILabel!
    
 
    
    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
               
                print(error)
            }
        }
        return nil
    }
    
    func convertStringToDictionaryArray(_ text: String) -> [String:[Int]]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:[Int]]
            } catch let error as NSError {
                
                print(error)
            }
        }
        return nil
    }
    
    struct raspi{
        static var hwaddr = " "
        static var ipaddr = " "
        static var deviceName = " "
    }
    
    
    
    
    @IBAction func device(_ sender: AnyObject) {
        
        
        
    }
    
   
    @IBAction func demo(_ sender: AnyObject) {
        
        print ("demo button pressed")
        
        
        /*
        let storyBoard : UIStoryboard = UIStoryboard(name: "swipeInfo", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("rootSwipe") as UIViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
        */
        
        if(raspi.deviceName == " "){
            print("device is not connected")
            self.deviceName?.text = "A device is not connected."
            
            
            
        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "home") as UIViewController
            
            self.present(nextViewController, animated:true, completion:nil)
            //self.navigationController!.pushViewController(nextViewController, animated: true)
            
            let todaysDate:Date = Date()
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            
            let DateInFormat:String = dateFormatter.string(from: todaysDate)
            
            let parameters = ["status": "on", "time": DateInFormat, "latitude": locat.lat, "longitude" : locat.lng, "method": "demo", "sampleId" : DateInFormat] as Dictionary<String, String>
            
            let url = URL(string: HOST)
            
            let session = URLSession.shared
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error in guard data != nil else {
                print("no data found: \(error)")
                return
                }
                
                do{
                    if let responseData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String{
                        
                        print(responseData)
                        
                        
                        
                    }else{
                        let responseStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print("Error bad response: \(responseStr)")
                    }
                }catch let parseError {
                    print(parseError)
                    let responseStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse string: \(responseStr)'")
                }
            }) 
            task.resume()
        
        }
        
    }
    
    
    
    @IBAction func sendInfo(_ sender: AnyObject) {
        
        print ("get info button pressed")
        
        
        
        if(raspi.hwaddr == " "){
            
            let UDIDaddr = UIDevice.current.identifierForVendor!.uuidString
            let parameters = ["HWaddr": UDIDaddr, "IPaddr": "198.168.1.116", "latitude": locat.lat, "longitude" : locat.lng, "method" : "info"] as Dictionary<String, String>
            
            
            let url = URL(string: HOST)
            let session = URLSession.shared
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error in guard data != nil else {
                print("no data found: \(error)")
                return
                }
                
                do{
                    if let responseData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String{
                        print(responseData)
                    }else{
                        let responseStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print("Error bad response: \(responseStr)")
                    }
                }catch let parseError {
                    print(parseError)
                    let responseStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse string: \(responseStr)'")
                }
                
                let responseData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
                let result = self.convertStringToDictionary(responseData!)
                
                raspi.hwaddr = result!["HWadd"] as! String
                raspi.ipaddr = result!["IPadd"] as! String
                raspi.deviceName = result!["ID"] as! String
                
                self.raspiHWaddr?.text =  "raspi serial: " + raspi.hwaddr
                self.raspiIPaddr?.text =  "raspi name: " + raspi.deviceName
                
                
                //print(raspi.hwaddr)
                //print(raspi.ipaddr)
                //print(raspi.deviceName)
            }) 
            
            task.resume()

            self.infoLabel?.text = "Did not work, check host and try again."
        }else{
            self.infoLabel?.text = "Info retrieved."
        }
        
    }


    @IBOutlet weak var devicen: UILabel!
    
    @IBOutlet weak var raspiHWaddr: UILabel!
    @IBOutlet weak var raspiIPaddr: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    
    func getData() -> String{
        return data
    }

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
      
        
        makeJSONRequest()
    
        /*
    self.processHist("10.403,22.957,4.9466,3.7065,1.8985,2.2052,0.89714,4.4819,2.4731,1.6585,1.9226,1.401,24.358,1.4156,3.4272,1.922,11.118,36.239,9.5494,2.7032,0.86807,2.4041,2.4411,17.949,0.61181,0.61926,29.266,1.4457,2.1919,5.1902,16.018,2.7236,2.4358,2.1865,2.9508,1.9233,0.33736,2.2064,0.89392,0.89892,0.90102,1.1491,2.1957,0.91957,1.1651,6.6964,1.4145,8.3639,4.7352,1.405,1.3788,9.5414,5.4788,23.541,1.9364,2.191,19.674,29.628,6.7235,1.9295,1.638")
 
 */

        self.raspiHWaddr?.text =  "raspi serial: " + raspi.hwaddr
        self.raspiIPaddr?.text =  "raspi name: " + raspi.deviceName
        
        if(raspi.deviceName == " "){
            self.deviceName?.text = "A device is not connected."
        }else{
            self.deviceName?.text = "You are connected to: "
        }
        

        
        //graph ranges for calibration histogram
        let graphRanges: [Int] = GraphView().ranges()

        self.graphHigh?.text = String(graphRanges[3])
        self.graphHighMed?.text = String(graphRanges[2])
        self.graphLowMed?.text = String(graphRanges[1])
        self.graphLow?.text = String(graphRanges[0])
        
        
        //scroll view size
        //scrollView.userInteractionEnabled = true
        //scrollView.contentSize = CGSize(width: 375, height: 1000)
        //set map view
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
        print("In ViewController: " + locat.lat + " " + locat.lng)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.raspiHWaddr?.text =  "raspi serial: " + raspi.hwaddr
        self.raspiIPaddr?.text =  "raspi name: " + raspi.deviceName
        self.devicen?.text = raspi.deviceName
    }

        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //GETS CURRENT LOCATION
    fileprivate let regionRadius: CLLocationDistance = 400
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let userLocation:CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        locat.lat = String(format: "%.4f", location.latitude)
        locat.lng = String(format: "%.4f", location.longitude)
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: " + error.localizedDescription)
        self.connectionProblem?.text = "Error: " + error.localizedDescription
    }

}

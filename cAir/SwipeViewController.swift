//
//  SwipeViewController.swift
//  cAir
//
//  Created by Taco on 7/28/16.
//  Copyright © 2016 Taco. All rights reserved.
//

import UIKit

class SwipeViewController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    
    struct bottomInfo{
        static var date: String = ""
        static var name: String = ""
    }
    
    @IBAction func indexChanged(_ sender: AnyObject) {
        
        
        switch segmentControl.selectedSegmentIndex{
        case 0:
           
            let scrollPoint = CGPoint(x: 0.0, y: 0.0)
            scrollView!.setContentOffset(scrollPoint, animated: true)
            
            
        case 1:
            
            let scrollPoint = CGPoint(x: self.view.frame.size.width, y: 0.0)
            scrollView!.setContentOffset(scrollPoint, animated: true)
        
        case 2:
            
            let scrollPoint = CGPoint(x: 2*(self.view.frame.size.width), y: 0.0)
            scrollView!.setContentOffset(scrollPoint, animated: true)
            
            
        default: break
            //do nothing
        }
        
    }

    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    @IBAction func homeButton(_ sender: AnyObject) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "homeNav") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
        
        }
    
    
    
    func loadScroll(){
        
        let vc0 = ViewController1(nibName: "ViewController1", bundle: nil)
        self.addChildViewController(vc0)
        self.scrollView.addSubview(vc0.view)
        vc0.didMove(toParentViewController: self)
        
        let vc1 = ViewController0(nibName: "ViewController0", bundle: nil)
        var frame1 = vc1.view.frame
        frame1.origin.x = self.view.frame.size.width
        
        vc1.view.frame = frame1
        
        self.addChildViewController(vc1)
        self.scrollView.addSubview(vc1.view)
        vc1.didMove(toParentViewController: self)
        segmentControl.selectedSegmentIndex = 1
        
        let vc2 = ViewController2(nibName: "ViewController2", bundle: nil)
        var frame2 = vc2.view.frame
        frame2.origin.x = self.view.frame.size.width * 2
        vc2.view.frame = frame2
        
        self.addChildViewController(vc2)
        self.scrollView.addSubview(vc2.view)
        vc2.didMove(toParentViewController: self)
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * 3, height: self.view.frame.size.height)
        
        
        let scrollPoint = CGPoint(x: self.view.frame.size.width, y: 0.0)
        scrollView!.setContentOffset(scrollPoint, animated: true)
        
    }
    
    func giveInfo(_ name: String, date: String){
        bottomInfo.date = date
        bottomInfo.name = name
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if bottomInfo.date != ""{
            self.dateTime.text  = bottomInfo.date
        }
        if bottomInfo.name != ""{
            self.deviceName.text = "Device name: " + bottomInfo.name
        }

        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        //self.navigationController!.navigationBar.hidden = true
        self.loadScroll()
        
        
      
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

}

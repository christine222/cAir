//
//  ViewController0.swift
//  cAir
//
//  Created by Taco on 7/28/16.
//  Copyright © 2016 Taco. All rights reserved.
//

import UIKit

class ViewController0: UIViewController {

    @IBOutlet weak var graphTitle: UILabel!
    
    @IBOutlet weak var graphHigh: UILabel!
    @IBOutlet weak var particleDensityLabel: UILabel!
    @IBOutlet weak var graphLow: UILabel!
    @IBOutlet weak var graphLowMed: UILabel!
    @IBOutlet weak var xLabels: UILabel!
    @IBOutlet weak var graphHighMed: UILabel!
    
    struct info{
        static var particle: String = " "
    }
    
    @IBOutlet weak var particleCount: UILabel!
    
    func giveParticle(_ amt: String){
        info.particle = amt
        
        
        
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.particleCount.text = "Number of Particles/L: " + info.particle
        let graphRanges: [Int] = GraphView().ranges()
        
        self.graphHigh?.text = String(graphRanges[3])
        self.graphHighMed?.text = String(graphRanges[2])
        self.graphLowMed?.text = String(graphRanges[1])
        self.graphLow?.text = String(graphRanges[0])

        // Do any additional setup after loading the view.
        
        self.particleDensityLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        
        self.xLabels?.text = "2    6    10    14    18    22    26    30    34    38    42"
        
        
        
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

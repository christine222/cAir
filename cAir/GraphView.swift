//
//  GraphView.swift
//  cAir
//
//  Created by Taco on 7/25/16.
//  Copyright © 2016 Taco. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    
    //sample testing data
    //var graphPointsY:[Int] = [58, 168, 53, 35, 5, 8, 3, 1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    //var graphPointsX:[Int] = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41]
    
    
    //1 - the properties for the gradient
    @IBInspectable var startColor: UIColor = UIColor.red
    @IBInspectable var endColor: UIColor = UIColor.green
    
    struct graphData{
        static var data: [Double] = [0]
    }
    
    //get data points from ViewController
    var data: Dictionary = ViewController().convertStringToDictionaryArray(ViewController().getData())!
    
    func giveGraphData(_ input: [Double]){
        graphData.data = input
    }

    
    //var graphPointsY:[Int] { get{ return (data["graphPointsY"])!}}
    var graphPointsY: [Double] {get {return graphData.data}}
    var graphPointsX:[Int] { get{ return (data["graphPointsX"])!}}
    
    func getMaxValue() -> Int {
        return Int(graphPointsY.max()!)
    }
    
    
    
    func ranges() -> [Int]{
        
        let max = Int(graphPointsY.max()!)
        
        var graphRange: [Int] = [0, 0, 0, 0]
        
        
        if max > 1000 && max < 1200{
            graphRange = [300, 600, 900, 1200] //1000 - 1200
        }else if max > 800 && max < 1000{
            graphRange = [250, 500, 750, 1000] //800 - 1000
        }else if max > 600 && max < 800{
            graphRange = [200, 400, 600, 800] //600 - 800
        }else if max > 400 && max < 600{
            graphRange = [150, 300, 450, 600] //400 - 600
        }else if max > 200 && max < 400{
            graphRange = [100, 200, 300, 400] //300 - 400
        }else if max > 100 && max < 200{
            graphRange = [50, 100, 150, 200] //100 - 200
        }else if max > 50 && max < 100{
            graphRange = [25, 50, 75, 100] //50 - 100
        }else if max < 50{
            graphRange = [15, 30, 45, 60]
        }else{
            graphRange = [(max/4), (max/2), (3*max/4), max]
        }
        
        return graphRange
    }
    
    //draw the graph
    override func draw(_ rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        let margin:CGFloat = 50.0 //graph margin
        let rightMargin: CGFloat = 35.0
        let graphWidth = width - (2 * margin)
        let topBorder:CGFloat = 50
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let graphRanges = ranges()
        let maxValue = graphRanges[3]
    
        
        
        
        
        
        
        //set up background clipping area
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient = CGGradient(colorsSpace: colorSpace,
                                                  colors: colors as CFArray,
                                                  locations: colorLocations)
        
        //6 - draw the gradient
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x:0, y:self.bounds.height)
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
       
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin*2 - 4) /
                CGFloat((self.graphPointsY.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        let columnYPoint = { (graphPoint:Int) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        
        UIColor.white.setFill()
        UIColor.white.setStroke()
        
        
        //Draw the steps on the graph and set stroke gradient
        for i in 0..<graphPointsY.count  {
            
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(Int(graphPointsY[i])))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let stepNumber = graphWidth / CGFloat(self.graphPointsY.count)
            
                let stepLine = UIBezierPath()
                stepLine.move(to: CGPoint(x:point.x, y: point.y))
                stepLine.addLine(to: CGPoint(x:point.x + stepNumber, y: point.y))
                stepLine.lineWidth = 2.0
            
                stepLine.stroke()
            
            
            let context = UIGraphicsGetCurrentContext()
            context?.move(to: CGPoint(x: point.x, y: point.y))
            context?.addLine(to: CGPoint(x: point.x + stepNumber, y: point.y))
            context?.addLine(to: CGPoint(x: point.x + stepNumber, y: height - bottomBorder))
            context?.addLine(to: CGPoint(x: point.x, y: height - bottomBorder))
            context?.addLine(to: CGPoint(x: point.x, y: point.y))
            context?.setFillColor(UIColor.white.cgColor)
            context?.fillPath()

            
            //1 - save the state of the context (commented out for now)
            context?.saveGState()
            
            //2 - make a copy of the path
            let clippingPath = stepLine.copy() as! UIBezierPath
            
            //3 - add lines to the copied path to complete the clip area
            clippingPath.addLine(to: CGPoint(
                x: point.x + stepNumber,
                y:height - bottomBorder))
            clippingPath.addLine(to: CGPoint(
                x:point.x,
                y:height - bottomBorder))
            clippingPath.close()
            
            //4 - add the clipping path to the context
            clippingPath.addClip()
            
            //5 - check clipping path
            //let highestYPoint = columnYPoint(maxValue)
         
            startPoint = CGPoint(x:margin, y: point.y)
            endPoint = CGPoint(x:margin, y:self.bounds.height)
        
            context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
            context?.restoreGState()

 
        }
        
        
        
        
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()
        
        //Top Line
        linePath.move(to: CGPoint(x:margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - rightMargin, y:topBorder))
        
        linePath.move(to: CGPoint(x:margin, y: height/2))
        linePath.addLine(to: CGPoint(x:width - rightMargin, y: height/2))
        
        linePath.move(to: CGPoint(x:margin, y: height/2 - (height - bottomBorder - topBorder)/4))
        linePath.addLine(to: CGPoint(x:width - rightMargin, y: height/2 - (height - bottomBorder - topBorder)/4))
        
        linePath.move(to: CGPoint(x:margin, y: height/2 + (height - bottomBorder - topBorder)/4))
        linePath.addLine(to: CGPoint(x:width - rightMargin, y: height/2 + (height - bottomBorder - topBorder)/4))
        
        //bottom line
        linePath.move(to: CGPoint(x:margin, y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:width - rightMargin, y:height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
    }
}

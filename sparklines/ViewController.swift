//
//  ViewController.swift
//  sparklines
//
//  Created by Jim Holt on 8/23/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var sparkLineView1: SparkLineView!
  @IBOutlet weak var sparkLineView2: SparkLineView!
  @IBOutlet weak var sparkLineView3: SparkLineView!
  @IBOutlet weak var sparkLineView4: SparkLineView!
  @IBOutlet weak var sparkLineView5: SparkLineView!
  @IBOutlet weak var sparkLineView6: SparkLineView!
  
  var allSparklines: [SparkLineView] = []
  
  var glucoseData: [NSNumber]     = []
  var temperatureData: [NSNumber] = []
  var heartRateData: [NSNumber]   = []

  let glucoseMinLimit: Float = 5.0
  let glucoseMaxLimit: Float = 6.8
  let tempMinLimit: Float = 36.9
  let tempMaxLimit: Float = 37.4
  let heartRateMinLimit: Float = 45
  let heartRateMaxLimit: Float = 85
  
  // MARK: NSObject lifecycle
  
  required convenience init(coder aDecoder: NSCoder) {
    self.init(aDecoder)
  }
  
  init(_ coder: NSCoder? = nil) {
    if let coder = coder {
      super.init(coder: coder)!
    }
    else {
      super.init(nibName: nil, bundle:nil)
    }
    
    loadData()
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
  }
  
  // MARK: Convenience
  
  func loadData() {
    glucoseData     = loadFile("glucose_data")
    temperatureData = loadFile("temperature_data")
    heartRateData   = loadFile("heartRate_data")
    
    assert(glucoseData.count > 0)
  }
  
  func loadFile( name: String) -> [NSNumber] {
    var data: [NSNumber] = []

    let dataFile = NSBundle.mainBundle().pathForResource(name, ofType: ".txt")
    let contents: String?
    do {
      try contents  = String( contentsOfFile: dataFile!, encoding: NSUTF8StringEncoding )
    } catch _ {
      contents = nil
      NSLog("failed to read in data file %@", name)
    }
    
    if (contents != nil) {
      
      let scanner = NSScanner(string:contents!)
      
      while !scanner.atEnd {
        var scannedValue: Double = 0.0
        if scanner.scanDouble(&scannedValue) {
          let num: NSNumber = scannedValue
          data.append(num)
        }
      }
    }

    return data
  }
  
  func setupViews() {
    // we have two test views to load
    
    let darkRed   = UIColor(red:0.6, green:0.0, blue:0.0, alpha:1.0)
    let darkGreen = UIColor(red:0.0, green:0.6, blue:0.0, alpha:1.0)
    
    // small ones are 1 - 3
    sparkLineView1.dataValues = glucoseData
    sparkLineView1.labelText = "Glucose"
    sparkLineView1.currentValueColor = darkRed
    
    sparkLineView2.dataValues = temperatureData
    sparkLineView2.labelText = "Temp"
    sparkLineView2.currentValueColor = darkGreen
    sparkLineView2.penColor = UIColor.blueColor()
    sparkLineView2.penWidth = 2.0
    
    sparkLineView3.dataValues = heartRateData
    sparkLineView3.labelText = "Pulse";
    sparkLineView3.currentValueColor = darkGreen
    sparkLineView3.currentValueFormat = "%.0f"
    sparkLineView3.penColor = UIColor.redColor()
    sparkLineView3.penWidth = 3.0
    
    // large ones are 4 - 6
    sparkLineView4.dataValues = glucoseData
    sparkLineView4.labelText = "Glucose"
    sparkLineView4.currentValueColor = darkRed
    
    sparkLineView5.dataValues = temperatureData
    sparkLineView5.labelText = "Temp"
    sparkLineView5.currentValueColor = darkGreen
    sparkLineView5.penColor = UIColor.blueColor()
    sparkLineView5.penWidth = 3.0
    
    sparkLineView6.dataValues = heartRateData
    sparkLineView6.labelText = "Pulse"
    sparkLineView6.currentValueColor = darkGreen
    sparkLineView6.currentValueFormat = "%.0f"
    sparkLineView6.penColor = UIColor.redColor()
    sparkLineView6.penWidth = 6.0
    
    allSparklines = [sparkLineView1, sparkLineView2, sparkLineView3,
                     sparkLineView4, sparkLineView5, sparkLineView6]
  }
  
  @IBAction func toggleCurrentValues(sender: AnyObject) {
    for (_, value) in allSparklines.enumerate() {
      value.showCurrentValue = !value.showCurrentValue
    
      let buttonText = String(format:"%@ Current Values", sparkLineView1.showCurrentValue ? "Hide" : "Show")
      let button = sender as! UIButton
      button.setTitle( buttonText, forState:UIControlState.Normal)
    }
  }

  @IBAction func toggleShowOverlays(sender: AnyObject) {
    for (_, value) in allSparklines.enumerate() {
      value.showRangeOverlay = !value.showRangeOverlay;
    
      let buttonText = String(format:"%@ Range Overlays", sparkLineView1.showRangeOverlay ? "Hide" : "Show")
      let button = sender as! UIButton
      button.setTitle( buttonText, forState:UIControlState.Normal)
    
      // if the overlays are enabled, we define the limits, otherwise we reset them (the view will auto-scale)
      if (sparkLineView1.showRangeOverlay) {
        
        sparkLineView1.rangeOverlayLowerLimit = glucoseMinLimit
        sparkLineView1.rangeOverlayUpperLimit = glucoseMaxLimit
        sparkLineView2.rangeOverlayLowerLimit = tempMinLimit
        sparkLineView2.rangeOverlayUpperLimit = tempMaxLimit
        sparkLineView3.rangeOverlayLowerLimit = heartRateMinLimit
        sparkLineView3.rangeOverlayUpperLimit = heartRateMaxLimit
        sparkLineView4.rangeOverlayLowerLimit = glucoseMinLimit
        sparkLineView4.rangeOverlayUpperLimit = glucoseMaxLimit
        sparkLineView5.rangeOverlayLowerLimit = tempMinLimit
        sparkLineView5.rangeOverlayUpperLimit = tempMaxLimit
        sparkLineView6.rangeOverlayLowerLimit = heartRateMinLimit
        sparkLineView6.rangeOverlayUpperLimit = heartRateMaxLimit
        
      } else {
        // make them all nil, which will result in an auto-scale of the data values
        for (_, value) in allSparklines.enumerate() {
          value.rangeOverlayLowerLimit = nil
          value.rangeOverlayUpperLimit = nil
        }
      }
    }
  }

}


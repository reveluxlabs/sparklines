//
//  ViewController.swift
//  sparklines
//
//  Created by Jim Holt on 8/23/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var sparkLineView1: LineSparkLineView!
  @IBOutlet weak var sparkLineView2: LineSparkLineView!
  @IBOutlet weak var sparkLineView3: LineSparkLineView!
  @IBOutlet weak var sparkLineView4: LineSparkLineView!
  @IBOutlet weak var sparkLineView5: LineSparkLineView!
  @IBOutlet weak var sparkLineView6: LineSparkLineView!
  
  @IBOutlet weak var sparkLineView7: WhiskerSparkLineView!
  @IBOutlet weak var sparkLineView8: WhiskerSparkLineView!
  
  var allSparklines: [LineSparkLineView] = []
  
  var glucoseData:     [NSNumber] = []
  var temperatureData: [NSNumber] = []
  var heartRateData:   [NSNumber] = []
  var baseballData:    [NSNumber] = []

  let glucoseMinLimit:   Float = 5.0
  let glucoseMaxLimit:   Float = 6.8
  let tempMinLimit:      Float = 36.9
  let tempMaxLimit:      Float = 37.4
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
    
//    UIFont.familyNames().map {UIFont.fontNamesForFamilyName($0)}
//      .forEach {(n:[String]) in n.forEach {print($0)}}
    
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
    baseballData    = loadFile("baseball_data")
    
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
    let scarlet   = UIColor(red:0.99, green:0.14, blue:0.22, alpha:1.0)
    
    // small ones are 1 - 3
    var lineSpark = LineSparkLine(data: glucoseData, label: "Glucose")
    lineSpark.currentValueColor = darkRed
    sparkLineView1.lineSpark = lineSpark
    
    lineSpark = LineSparkLine(data: temperatureData, label: "Temp")
    lineSpark.currentValueColor = darkGreen
    lineSpark.penColor = UIColor.blueColor()
    lineSpark.penWidth = 2.0
    sparkLineView2.lineSpark = lineSpark
    
    lineSpark = LineSparkLine(data: heartRateData, label: "Pulse")
    lineSpark.currentValueColor = darkGreen
    lineSpark.currentValueFormat = "%.0f"
    lineSpark.penColor = scarlet
    lineSpark.penWidth = 3.0
    sparkLineView3.lineSpark = lineSpark
    
    // large ones are 4 - 6
    lineSpark = LineSparkLine(data: glucoseData, label: "Glucose")
    lineSpark.currentValueColor = darkRed
    sparkLineView4.lineSpark = lineSpark
    
    lineSpark = LineSparkLine(data: temperatureData, label: "Temp")
    lineSpark.currentValueColor = darkGreen
    lineSpark.penColor = UIColor.blueColor()
    lineSpark.penWidth = 3.0
    sparkLineView5.lineSpark = lineSpark
    
    lineSpark = LineSparkLine(data: heartRateData, label: "Pulse")
    lineSpark.currentValueColor = darkGreen
    lineSpark.currentValueFormat = "%.0f"
    lineSpark.penColor = scarlet
    lineSpark.penWidth = 6.0
    sparkLineView6.lineSpark = lineSpark
    
    allSparklines = [sparkLineView1, sparkLineView2, sparkLineView3,
                     sparkLineView4, sparkLineView5, sparkLineView6]
    
    let unboxedBaseball = baseballData.map({ $0.doubleValue })
  
    var whiskerSpark = WhiskerSparkLine( data: [], label: "games", xIncrement: 3.0, whiskerWidth: 1.0 )
    whiskerSpark.dataSource = StreakDataSource( values: unboxedBaseball, streakLength: 4 )
    whiskerSpark.labelFont            = "Baskerville"
    whiskerSpark.currentValueFormat   = " %.0f"
    whiskerSpark.labelColor           = scarlet
    whiskerSpark.centerSparkLine      = false
    whiskerSpark.showHighlightOverlay = true
    sparkLineView7.whiskerSpark       = whiskerSpark

    let randomBaseball = generateRandomRecord( 96, losses: 66 )

    whiskerSpark = WhiskerSparkLine( data: [], label: "", xIncrement: 3.0, whiskerWidth: 1.0 )
    whiskerSpark.dataSource = StreakDataSource( values: randomBaseball, streakLength: 4 )
    whiskerSpark.labelFont            = "Baskerville"
    whiskerSpark.currentValueFormat   = "    %.0f"
    whiskerSpark.labelColor           = scarlet
    whiskerSpark.centerSparkLine      = false
    whiskerSpark.showHighlightOverlay = true
    sparkLineView8.whiskerSpark       = whiskerSpark
  }
  
  func generateRandomRecord( wins: Int, losses: Int ) -> [Double] {
    var result: [Double] = []
    var r: Double
    let winPercent: Double = Double(wins)/Double(wins + losses)
    
    let t = time(UnsafeMutablePointer(bitPattern: 0))
    srand48(t)
    for _ in 1...162 {
      r = drand48()
     
      if r > winPercent {
        result.append( -1.0 )
      } else {
        result.append( 1.0 )
      }
    }
    
    return result
  }
  
  @IBAction func toggleCurrentValues(sender: AnyObject) {
    for (_, value) in allSparklines.enumerate() {
      value.lineSpark!.showCurrentValue = !value.lineSpark!.showCurrentValue
      value.setNeedsDisplay()
    }
    
    let buttonText = String(format:"%@ Current Values", sparkLineView1.lineSpark!.showCurrentValue ? "Hide" : "Show")
    let button = sender as! UIButton
    button.setTitle( buttonText, forState:UIControlState.Normal)
  }

  @IBAction func toggleShowOverlays(sender: AnyObject) {
    for (_, value) in allSparklines.enumerate() {
      value.lineSpark!.showRangeOverlay = !value.lineSpark!.showRangeOverlay
      value.setNeedsDisplay()
    }
   
    let buttonText = String(format:"%@ Range Overlays", sparkLineView1.lineSpark!.showRangeOverlay ? "Hide" : "Show")
    let button = sender as! UIButton
    button.setTitle( buttonText, forState:UIControlState.Normal)
  
    // if the overlays are enabled, we define the limits, otherwise we reset them (the view will auto-scale)
    if (sparkLineView1.lineSpark!.showRangeOverlay) {
      
      sparkLineView1.lineSpark!.rangeOverlayLowerLimit = glucoseMinLimit
      sparkLineView1.lineSpark!.rangeOverlayUpperLimit = glucoseMaxLimit
      sparkLineView2.lineSpark!.rangeOverlayLowerLimit = tempMinLimit
      sparkLineView2.lineSpark!.rangeOverlayUpperLimit = tempMaxLimit
      sparkLineView3.lineSpark!.rangeOverlayLowerLimit = heartRateMinLimit
      sparkLineView3.lineSpark!.rangeOverlayUpperLimit = heartRateMaxLimit
      sparkLineView4.lineSpark!.rangeOverlayLowerLimit = glucoseMinLimit
      sparkLineView4.lineSpark!.rangeOverlayUpperLimit = glucoseMaxLimit
      sparkLineView5.lineSpark!.rangeOverlayLowerLimit = tempMinLimit
      sparkLineView5.lineSpark!.rangeOverlayUpperLimit = tempMaxLimit
      sparkLineView6.lineSpark!.rangeOverlayLowerLimit = heartRateMinLimit
      sparkLineView6.lineSpark!.rangeOverlayUpperLimit = heartRateMaxLimit
      
    } else {
      // make them all nil, which will result in an auto-scale of the data values
      for (_, value) in allSparklines.enumerate() {
        value.lineSpark!.rangeOverlayLowerLimit = nil
        value.lineSpark!.rangeOverlayUpperLimit = nil
      }
    }
  }

  @IBAction func regenerateSeason(sender: AnyObject) {
    
    let randomBaseball = generateRandomRecord( 96, losses: 66 )
    sparkLineView8.whiskerSpark!.dataSource = StreakDataSource( values: randomBaseball, streakLength: 4 )
    
    sparkLineView8.setNeedsDisplay()
  }
}


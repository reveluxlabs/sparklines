//
//  StreakDataSource.swift
//  sparklines
//
//  Created by Jim Holt on 9/2/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

struct StreakDataSource: WhiskerSparkLineDataSource {

  var    selectedStreakLength: Int = 4
  var    tickInterval:         Int = 5

  var    values: [Double] {
    didSet {
      whiskerInfo = prepareDataSourceForWhiskerView( values )
      longestRun  = whiskerInfo.longest
      streakMap   = whiskerInfo.map
      boxedValues = whiskerInfo.boxedValues
    }
  }
  
  var    boxedValues:        [NSNumber]? = []
  var    selectedStreakState: ActivityState = .Active
  var    streakMap:           [Bool]? = []
  var    longestRun:          Int? = 0
  
  var whiskerInfo: (longest: Int, map: [Bool], boxedValues: [NSNumber])
    = (longest: 0, map: [], boxedValues: [])

  init( values: [Double]) {
    self.values = values
    selectedStreakState = .Active
    whiskerInfo = prepareDataSourceForWhiskerView( values )
    longestRun  = whiskerInfo.longest
    streakMap   = whiskerInfo.map
    boxedValues = whiskerInfo.boxedValues

  }
  
  // MARK: Sparkline data source methods
  
  func dataPointForIndex( sparkLineView: SparkLinePlotter, index:Int) -> NSNumber {

    let result = boxedValues![index]
    
    return result
  }
  
  func whiskerColorForIndex( sparkLineView: SparkLinePlotter, index:Int ) -> UIColor {

    let whiskerView = sparkLineView as! WhiskerSparkLineView
    if streakMap![index].boolValue {
      return whiskerView.highlightedWhiskerColor
    }
    
    return whiskerView.whiskerColor
  }
  
  func tickForIndex( sparkLineView: SparkLinePlotter, index:Int  ) -> Bool {
    // ticks turned off
    if (tickInterval == 0) { return false }
    
    // ticks on
    
    // tick at this index?
    if (index % tickInterval == 0) { return true }
    
    return false
  }
  
  func numberOfDataPoints( sparkLineView: SparkLinePlotter ) -> Int {
    let result = boxedValues!.count
    
    return result
  }
  
  func longestRun( sparkLineView: SparkLinePlotter ) -> Int {
    let result = longestRun!
    
    return result
  }
  
}


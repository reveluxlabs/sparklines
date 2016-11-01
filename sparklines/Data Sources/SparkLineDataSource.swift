
//
//  SparkLineDataSource.swift
//  sparklines
//
//  Created by Jim Holt on 8/30/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

protocol SparkLineDataSource {
  func dataPointForIndex( _ sparkLineView: SparkLinePlotter, index:Int) -> NSNumber
  func numberOfDataPoints( _ sparkLineView: SparkLinePlotter ) -> Int
  func values() -> [NSNumber]
}

protocol WhiskerSparkLineDataSource: SparkLineDataSource {
  
  var    selectedStreakLength: Int           {get set}
  var    tickInterval:         Int           {get set}
  
  var    dataValues:           [Double]      {get set}
  var    streakType:  ActivityState {get set}
  
  var    streaks:              [Int:Int]     {get set}
  var    streakMap:            [Bool]?       {get set}
  var    longestRun:           Int?          {get set}

  init( values: [Double], streakLength: Int )
  
  func whiskerColorForIndex( _ sparkLineView: SparkLinePlotter, index:Int ) -> UIColor
  func tickForIndex( _ sparkLineView: SparkLinePlotter, index:Int  ) -> Bool
  func longestRun( _ sparkLineView: SparkLinePlotter ) -> Int

}

enum ActivityState: Int {
  case active      = 1
  case notTracking = 0
  case inactive    = -1
}

extension WhiskerSparkLineDataSource {
  
  mutating func prepareDataSourceForWhiskerView( _ values: [Double] ) -> (Int, [Bool], [NSNumber] ) {
    var streakInfo: (longest: Int, streaks: [Int:Int], map: [Bool])
    let boxedValues = values.map( { NSNumber(value: $0 as Double) } )
    
    guard boxedValues.count > 0 else {
      return ( longestRun!, streakMap!, boxedValues )
    }
    
    streakInfo = mapStreaks( boxedValues,
                             greaterThanOrEqual: selectedStreakLength,
                             binaryState: streakType )
    
    streaks    = streakInfo.streaks
    streakMap  = streakInfo.map
    longestRun = streakInfo.longest
    
    return ( longestRun!, streakMap!, boxedValues )
  }
  
  func mapStreaks( _ boxedValues: [NSNumber], greaterThanOrEqual length: Int, binaryState type: ActivityState ) -> ( Int, [Int:Int], [Bool] ) {
    
    var    streaks:      [Int:Int]?
    var    streakMap:    [Bool]?
    
    assert(boxedValues.count > 0)
    
    streaks      = [:]
    streakMap    = []
    
    streakMap = boxedValues.map( { _ in false } )
    
    streaks = findRuns( boxedValues, greaterThanOrEqual: length, binaryState: type )
    
    for (start, len) in streaks! {
      
      if (len >= length ) {
        for i in start ..< (start + len) {
          streakMap![i] = true
        }
      }
    }
    
    let longest = Array(streaks!.values).max()
    return ( longest!, streaks!, streakMap! )
  }
  
  func findRuns( _ boxedValues: [NSNumber], greaterThanOrEqual length: Int, binaryState type: ActivityState ) -> [Int:Int] {
    
    var    streaks:              [Int:Int]? = [1:1]
    var    runLength:            Int        = 0
    var    lastWhiskerValue:     Float      = boxedValues[0].floatValue
    
    let last = boxedValues.count
    
    for (index, value) in boxedValues.enumerated() {
      
      if index < last && value.floatValue == lastWhiskerValue  {
        
        // Run continues
        
        runLength += 1
        
      } else {
        
        // Run ending
        
        let runStart = index - runLength
        if Int(boxedValues[runStart]) == type.rawValue && runLength >= length {
          streaks![runStart] = runLength
        }
        
        // More entries, reset
        
        if index < last {
          lastWhiskerValue = boxedValues[index].floatValue
          runLength = 1
        }
      }
    }
    
    return streaks!
  }

}

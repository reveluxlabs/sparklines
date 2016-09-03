
//
//  SparkLineDataSource.swift
//  sparklines
//
//  Created by Jim Holt on 8/30/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

protocol SparkLineDataSource {
  func dataPointForIndex( sparkLineView: SparkLinePlotter, index:Int) -> NSNumber
  func numberOfDataPoints( sparkLineView: SparkLinePlotter ) -> Int
}

protocol WhiskerSparkLineDataSource: SparkLineDataSource {
  
  var    selectedStreakLength: Int           {get set}
  var    tickInterval:         Int           {get set}
  
  var    values:               [Double]      {get set}
  var    selectedStreakState:  ActivityState {get set}
  
  var    streakMap:            [Bool]?       {get set}
  var    longestRun:           Int?          {get set}

  init( values: [Double])
  
  func whiskerColorForIndex( sparkLineView: SparkLinePlotter, index:Int ) -> UIColor
  func tickForIndex( sparkLineView: SparkLinePlotter, index:Int  ) -> Bool
  func longestRun( sparkLineView: SparkLinePlotter ) -> Int

}

enum ActivityState: Int {
  case Active      = 1
  case NotTracking = 0
  case Inactive    = -1
}

extension WhiskerSparkLineDataSource {
  
  mutating func prepareDataSourceForWhiskerView( values: [Double] ) -> (Int, [Bool], [NSNumber] ) {
    var streakInfo: (longest: Int, map: [Bool])
    let boxedValues = values.map( { NSNumber( double: $0 ) } )
    guard boxedValues.count > 0 else {
      return ( longestRun!, streakMap!, boxedValues )
    }
    
    streakInfo = mapStreaks( boxedValues,
                             greaterThanOrEqual: selectedStreakLength,
                             binaryState: selectedStreakState )
    streakMap  = streakInfo.map
    longestRun = streakInfo.longest
    
    return ( longestRun!, streakMap!, boxedValues )
  }
  
  func mapStreaks( boxedValues: [NSNumber], greaterThanOrEqual length: Int, binaryState type: ActivityState ) -> ( Int, [Bool] ) {
    
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
    
    let longest = Array(streaks!.values).maxElement()
    return ( longest!, streakMap! )
  }
  
  func findRuns( boxedValues: [NSNumber], greaterThanOrEqual length: Int, binaryState type: ActivityState ) -> [Int:Int] {
    
    var    streaks:              [Int:Int]? = [:]
    var    runLength:            Int        = 0
    var    lastWhiskerValue:     Float      = boxedValues[0].floatValue
    
    let last = boxedValues.count
    
    for (index, value) in boxedValues.enumerate() {
      
      if index < last && value.floatValue == lastWhiskerValue  {
        
        // Run continues
        
        runLength += 1
        
      } else {
        
        // Run ending
        
        let runStart = index - runLength
        if boxedValues[runStart] == type.rawValue && runLength >= length {
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
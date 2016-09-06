//
//  BinDataSource.swift
//  sparklines
//
//  Created by Jim Holt on 9/1/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

struct IntervalWindow {
  
  let streakLength: Int
  let tickInterval: Int
}

struct Accumulator {
  
  let value: Double
  
  init( value: Double) {
    self.value = value
  }
  
  func binaryOutcome() -> Bool {
    if value == 1.0 {
      return true

    } else {
      return false
    }
  }
}

enum ActivityState: Int {
  case Active      = 1
  case NotTracking = 0
  case Inactive    = -1
}

struct BinDataSource: SparkLineDataSource {
  
  var    bins: [Accumulator] {
    didSet {
      prepareDataSourceForWhiskerView( bins )
    }
  }
  
  var    intervalWindow: IntervalWindow
  var    binaryValues: [NSNumber]?
  var    streakMap: [Bool]?
  var    streakState: ActivityState

  init( bins: [Accumulator]) {
    self.bins = bins
    intervalWindow = IntervalWindow(streakLength: 4, tickInterval: 5)
    streakState = .Active
    prepareDataSourceForWhiskerView( bins )
  }

  // MARK: Data prep stuff

  mutating func prepareDataSourceForWhiskerView( bins: [Accumulator] ) {

    binaryValues = createBinaryValues( bins )
    guard binaryValues!.count > 0 else {
      return
    }
  
    streakMap = findStreaks( binaryValues!,
                             greaterThanOrEqual: intervalWindow.streakLength,
                             binaryState: streakState )
  }
  
  func createBinaryValues( data: [Accumulator] ) -> [NSNumber] {
    // Returns an array of NSNumbers with the data values mapped to binary outcomes.
    var dataValues: [NSNumber] = []

    for (_, accumulator) in data.enumerate() {
    
      dataValues.append( NSNumber( double: accumulator.value ) )
    }
  
    return dataValues
  }
  
  func findStreaks( binaryValues: [NSNumber], greaterThanOrEqual length: Int, binaryState type: ActivityState ) -> [Bool] {

    var    streaks:      [Int:Int]?
    var    streakMap:    [Bool]?
    var    streakLength: Int
    var    streakType:   Float
  
    assert(binaryValues.count > 0)
  
    streaks      = [:]
    streakMap    = []
    streakLength = 0
    streakType   = binaryValues[0].floatValue
    
    let count = binaryValues.count
    for _ in 1...count {
      streakMap!.append( false )
    }
    
    for (index, value) in binaryValues.enumerate() {
  
      if index < count &&
        streakType == value.floatValue {
        streakLength += 1
        
      } else {

        if binaryValues[index - streakLength] == type.rawValue &&
          streakLength >= length {
          streaks![index-streakLength] = streakLength
        }

        if index < count {
          streakType = binaryValues[index].floatValue
          streakLength = 1
        }
      }
    }
  
    for (start, length) in streaks! {
      
      if (length >= 4 ) {
        for i in start ..< (start + length) {
          streakMap![i] = true
        }
      }
    }
  
    return streakMap!
  }

  // MARK: Sparkline data source methods
  
  func dataPointForIndex( sparkLineView: SparkLinePlotter, index:Int) -> NSNumber {
    var    result: NSNumber
  
    result = binaryValues![index]
  
    return result
  }
  
  func whiskerColorForIndex( sparkLineView: SparkLinePlotter, index:Int ) -> UIColor {
    var bin: Int
  
    bin = index
    if streakMap![bin].boolValue {
      return UIColor.redColor()    // sparkLineView.highlightedWhiskerColor
    }
    
    return UIColor.blackColor()    // sparkLineView.whiskerColor
  }
  
  func tickForIndex( sparkLineView: SparkLinePlotter, index:Int  ) -> Bool {
    // ticks turned off
    if (self.intervalWindow.tickInterval == 0) { return false }
  
    // ticks on
  
    // tick at this index?
    if (index % intervalWindow.tickInterval == 0) { return true }
  
    return false
  }
  
  func numberOfDataPoints( sparkLineView: SparkLinePlotter ) -> Int {

    var result: Int
  
    result = binaryValues!.count
  
    //  NSLog(@"bin data source providing number of data points %lu", result);
    return result;
  }

}


//
//  TestDataSource.swift
//  sparklines
//
//  Created by Jim Holt on 8/30/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

struct TestDataSource: WhiskerSparkLineDataSource {
  
  var dataValues: [NSNumber]
  
  init( dataValues: [NSNumber] )  {
    self.dataValues = dataValues
  }
  
  func dataPointForIndex( sparkLineView: SparkLinePlotter, index:Int) -> NSNumber {
    assert(index < dataValues.count)
    return dataValues[index]
  }

  func numberOfDataPoints( sparkLineView: SparkLinePlotter ) -> Int { return dataValues.count }
  
  func whiskerColorForIndex( sparkLineView: SparkLinePlotter, index:Int ) -> UIColor  {
    var result = UIColor.blackColor()
    
    if (6...12).contains(index) {
      result = UIColor.redColor()
    }
    return result
  }

  func tickForIndex( sparkLineView: SparkLinePlotter, index:Int  ) -> Bool {
    var result = false
    if index == 5 {
      result = true
    }
    
    return result
  }
  
  func timeForIndex( sparkLineView: SparkLinePlotter, index:Int  ) -> Bool { return false }

}

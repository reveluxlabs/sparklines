//
//  TestDataSource.swift
//  sparklines
//
//  Created by Jim Holt on 8/30/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

struct TestDataSource: SparkLineDataSource {
  
  var dataValues: [NSNumber]
  
  init( dataValues: [NSNumber] )  {
    self.dataValues = dataValues
  }
  
  func dataPointForIndex( _ sparkLineView: SparkLinePlotter, index:Int) -> NSNumber {
    assert(index < dataValues.count)
    return dataValues[index]
  }

  func numberOfDataPoints( _ sparkLineView: SparkLinePlotter ) -> Int { return dataValues.count }
  
  func values() -> [NSNumber] { return dataValues }
  
  func whiskerColorForIndex( _ sparkLineView: SparkLinePlotter, index:Int ) -> UIColor  {
    var result = UIColor.black
    
    if (6...12).contains(index) {
      result = UIColor.red
    }
    return result
  }

  func tickForIndex( _ sparkLineView: SparkLinePlotter, index:Int  ) -> Bool {
    var result = false
    if index == 5 {
      result = true
    }
    
    return result
  }
  
  func timeForIndex( _ sparkLineView: SparkLinePlotter, index:Int  ) -> Bool { return false }

}

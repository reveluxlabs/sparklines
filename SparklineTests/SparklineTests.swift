//
//  SparklineTests.swift
//  SparklineTests
//
//  Created by Jim Holt on 9/6/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import XCTest
import Nimble

class SparklineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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

}

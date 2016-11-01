//
//  SparkLineLabelTests.swift
//  sparklines
//
//  Created by Jim Holt on 9/8/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import XCTest
import Nimble

@testable import sparklines

class SparkLineLabelTests: SparklineTests {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func createAnonymousLabel() -> SparkLineLabel {
    let sll = SparkLineLabel(bounds: CGRect(x: 0,y: 0,width: 600,height: 40),
                             count: 162,
                             text: " games",
                             font: "Baskerville",
                             value: 5.0,
                             showValue: true,
                             valueColor: UIColor.black,
                             valueFormat: "%.0f",
                             reverse: true)
    
    return sll
  }
  
  func testCreate() {
    
    let label = createAnonymousLabel()
    
    expect(label).notTo(beNil())
  }

  func testHasFormattedGraphText() {
    // setup
    let label = createAnonymousLabel()

    // execute
    let fgt = label.formattedGraphText

    // verify
    expect(fgt).to(equal("5 games"))
  }
  

}

//
//  PlotSpaceTests.swift
//  sparklines
//
//  Created by Jim Holt on 9/7/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import XCTest
import Nimble

@testable import sparklines

class PlotSpaceTests: SparklineTests {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func createAnonymousPlotSpace() -> PlotSpace {
    let ps = PlotSpace(bounds: CGRectZero, dataMinimum: -1.0, dataMaximum: 1.0)
    return ps
  }

  func createPlotSpace(bounds b: CGRect, dataMinimum min: Float, dataMaximum max: Float) -> PlotSpace {
    let ps = PlotSpace(bounds: b, dataMinimum: min, dataMaximum: max)
    return ps
  }
  
  func testCreate() {

    let ps = createAnonymousPlotSpace()

    expect(ps).notTo(beNil())
  }
  
  func testShouldHaveFullHeight() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.fullHeight).to(equal(40.0))
  }
  
  func testShouldHaveFullWidth() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.fullWidth).to(equal(600.0))
  }
  
  func testShouldHaveDataMin() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.dataMin).to(equal(-1.0))
  }
  
  func testShouldHaveDataMax() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.dataMax).to(equal(1.0))
  }
  
  func testShouldHaveGraphMin() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.graphMin).to(equal(-1.0))
  }
  
  func testShouldHaveGraphMax() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.graphMax).to(equal(1.0))
  }
  
  func testShouldHaveGraphSize_textWidthZero() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.graphSize).to(equal(570.0))
  }
  
  func testShouldHaveGraphSize_textWidth40() {
    
    var ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    ps.textWidth = 40.0
    
    expect(ps.graphSize).to(equal(530.0))
  }
  
  func testShouldHaveGraphFrac() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.graphFrac).to(equal(0.95))
  }
  
  func testShouldHaveSparkWidth() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.sparkWidth).to(beCloseTo(566.2))
  }
  
  func testShouldHaveSparkHeight() {
    
    let ps = createPlotSpace( bounds: CGRectMake(0, 0, 600, 40), dataMinimum: -1.0, dataMaximum: 1.0 )
    
    expect(ps.sparkHeight).to(equal(36.0))
  }
  
}

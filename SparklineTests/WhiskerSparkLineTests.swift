//
//  WhiskerSparkLineTests.swift
//  sparklines
//
//  Created by Jim Holt on 9/7/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import XCTest
import Nimble

@testable import sparklines

class WhiskerSparkLineTests: SparklineTests {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  // MARK: Factory methods
  
  func createAnonymousWhiskerSparkLine() -> WhiskerSparkLine {
    let wsl = WhiskerSparkLine(data: [], label: "Test")
    return wsl
  }
  
  func createSparklineWithStreakDataSource( fileName: String ) -> WhiskerSparkLine {
    let baseballData    = loadFile(fileName)
    let unboxedBaseball = baseballData.map({ $0.doubleValue })
    let dataSource      = StreakDataSource( values: unboxedBaseball, streakLength: 4 )
    var spark = createAnonymousWhiskerSparkLine()
    
    spark.dataSource = dataSource

    return spark
  }
  
  func assertThatCommandsEqual( commands: [String], expected: [String] ) {
    
    for (index, cmd) in commands.enumerate() {
      expect(cmd).to(equal(expected[index]))
    }
  }
  
  // MARK: Tests
  
  func testCreate() {
    
    let spark = createAnonymousWhiskerSparkLine()
    
    expect(spark).notTo(beNil())
  }
  
  // MARK: Properties
  
  func testHasDataValues() {
    
    let spark = createAnonymousWhiskerSparkLine()
    
    expect(spark.dataValues).notTo(beNil())
  }
  
  func testHasLabelText() {
    
    let spark = createAnonymousWhiskerSparkLine()
    
    expect(spark.labelText).notTo(beNil())
  }
  
  func testHasDataSource() {
    
    let spark = createSparklineWithStreakDataSource("baseball_data")
    
    expect(spark.dataSource).notTo(beNil())
  }
  
  func testHasLabelFont() {
    // setup
    var spark = createAnonymousWhiskerSparkLine()
    let fontName = "Baskerville"
    
    // execute
    spark.labelFont = fontName
    
    // verify
    expect(spark.labelFont).to(equal(fontName))
  }
  
  func testHasXIncrement() {
    // setup
    var spark         = createAnonymousWhiskerSparkLine()
    let xInc: CGFloat = 3.0
    
    // execute
    spark.xIncrement = xInc
    
    // verify
    expect(spark.xIncrement).to(equal(xInc))
  }
  
  func testHasValueFormat() {
    // setup
    var spark    = createAnonymousWhiskerSparkLine()
    let format   = " %.0f"
    
    // execute
    spark.currentValueFormat   = format
    
    // verify
    expect(spark.currentValueFormat).to(equal(format))
  }

  func testHasLabelColor() {
    // setup
    var spark     = createAnonymousWhiskerSparkLine()
    let scarlet   = UIColor(red:0.99, green:0.14, blue:0.22, alpha:1.0)
    
    // execute
    spark.labelColor           = scarlet
    
    // verify
    expect(spark.labelColor).to(equal(scarlet))
  }
  
  func testHasPenWidth() {
    // setup
    var spark            = createAnonymousWhiskerSparkLine()
    let width: CGFloat   = 1.0
    
    // execute
    spark.penWidth = width
    
    // verify
    expect(spark.penWidth).to(equal(width))
  }
  
  func testHasCenterSparkline() {
    // setup
    var spark     = createAnonymousWhiskerSparkLine()
    
    // execute
    spark.centerSparkLine      = false
    
    // verify
    expect(spark.centerSparkLine).to(beFalse())
  }
  
  func testHasShowHighlightOverlay() {
    // setup
    var spark     = createAnonymousWhiskerSparkLine()
    
    // execute
    spark.showHighlightOverlay = true
    
    // verify
    expect(spark.showHighlightOverlay).to(beTrue())
  }
  
  // MARK: Plot space setup
  
  func testShouldComputeRanges() {
    // setup
    var spark = createSparklineWithStreakDataSource("baseball_data")
    
    // execute
    spark.computeRanges([])
    
    // verify
    expect(spark.dataMaximum).to(equal(1.0))
    expect(spark.dataMinimum).to(equal(-1.0))
  }
 
  func testHasValueForLabel() {
    // setup
    let spark = createSparklineWithStreakDataSource("baseball_data")
    
    // execute
    let v = spark.valueForLabel()
    
    // verify
    expect(v).to(equal(5))
  }
  
  // MARK: Drawing
  
  func testShouldDraw_whisker() {
    // setup
    let spark    = createAnonymousWhiskerSparkLine()
    let renderer = TestRenderer()
    
    // execute
    spark.drawWhiskerAtXpos(10.0, ypos: 20.0, centerY: 20.0, renderer: renderer)
    
    // verify
    let whiskerCommands = ["setLineWidth(0.5)",
                           "moveTo(10.0, 20.0)",
                           "lineTo(10.0, 20.0)",
                           "closePath()",
                           "strokePath()" ]
    expect(renderer.commands.count).to(equal(5))
    assertThatCommandsEqual( renderer.commands, expected: whiskerCommands )
  }
  
  func testShouldDraw_sparkline() {
    // setup
    var spark    = createSparklineWithStreakDataSource("test_whisker_1")
    expect(spark.dataSource!.numberOfDataPoints(spark)).to(equal(1))
    let renderer = TestRenderer()
    
    // execute
    spark.draw( CGRectMake(0,0,600,40), renderer: renderer )
    
    // verify
    let whiskerCommands = ["setLineWidth(0.5)",
                           "setStroke(UIDeviceWhiteColorSpace 0 1)",
                           "beginPath()",
                           "setStroke(UIDeviceWhiteColorSpace 0 1)",
                           "setLineWidth(0.5)",
                           "moveTo(301.5, 20.0)",
                           "lineTo(301.5, 12.0)",
                           "closePath()",
                           "strokePath()",
                           "setStroke(UIDeviceRGBColorSpace 0.960784 0.960784 0.960784 0.1)",
                           "setLineWidth(2.0)",
                           "moveTo(300.5, 0.0)",
                           "lineTo(300.5, 40.0)",
                           "closePath()",
                           "strokePath()",
                           "setStroke(UIDeviceRGBColorSpace 0.960784 0.960784 0.960784 0.1)",
                           "setLineWidth(2.0)",
                           "moveTo(302.5, 0.0)",
                           "lineTo(302.5, 40.0)",
                           "closePath()",
                           "strokePath()",
                           "setLineWidth(0.5)",
                           "setStroke(UIDeviceWhiteColorSpace 0 1)",
                           "moveTo(301.5, 20.0)",
                           "lineTo(302.0, 20.0)",
                           "closePath()",
                           "strokePath()"]
    
    expect(renderer.commands.count).to(equal(27))
    assertThatCommandsEqual( renderer.commands, expected: whiskerCommands )
  }
  
  

}
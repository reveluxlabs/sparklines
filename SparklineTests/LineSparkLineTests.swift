//
//  LineSparkLineTests.swift
//  sparklines
//
//  Created by Jim Holt on 9/8/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import XCTest
import Nimble

@testable import sparklines

class LineSparkLineTests: SparklineTests {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  // MARK: Factory methods
  
  func createAnonymousLineSparkLine() -> LineSparkLine {
    let lsl = createLineSparkLine(data: [], label: "Test")
    return lsl
  }
  
  func createLineSparkLine( data d: [NSNumber], label l: String ) -> LineSparkLine {
    let lsl = LineSparkLine(data: d, label: l)
    return lsl
  }
  
  func createSparklineWithData( fileName: String, label l: String ) -> LineSparkLine {
    let lineData = loadFile(fileName)
    let spark    = createLineSparkLine( data: lineData, label: l )
    return spark
  }

  //  func createSparklineWithStreakDataSource( fileName: String ) -> WhiskerSparkLine {
  //    let baseballData    = loadFile(fileName)
  //    let unboxedBaseball = baseballData.map({ $0.doubleValue })
  //    let dataSource      = StreakDataSource( values: unboxedBaseball, streakLength: 4 )
  //    var spark = createAnonymousLineSparkLine()
  //    
  //    spark.dataSource = dataSource
  //    
  //    return spark
  //  }
  
  func assertThatCommandsEqual( commands: [String], expected: [String] ) {
    
    for (index, cmd) in commands.enumerate() {
      expect(cmd).to(equal(expected[index]))
    }
  }
  
  // MARK: Tests
  
  func testCreate() {
    
    let spark = createAnonymousLineSparkLine()
    
    expect(spark).notTo(beNil())
  }
  
  // MARK: Properties
  
  func testHasDataValues() {
    
    let spark = createAnonymousLineSparkLine()
    
    expect(spark.dataValues).notTo(beNil())
  }
  
  func testHasLabelText() {
    
    let spark = createAnonymousLineSparkLine()
    
    expect(spark.labelText).notTo(beNil())
  }
  
//  func testHasDataSource() {
//    
//    let spark = createSparklineWithStreakDataSource("baseball_data")
//    
//    expect(spark.dataSource).notTo(beNil())
//  }
  
  func testHasLabelFont() {
    // setup
    var spark = createAnonymousLineSparkLine()
    let fontName = "Baskerville"
    
    // execute
    spark.labelFont = fontName
    
    // verify
    expect(spark.labelFont).to(equal(fontName))
  }
  
  func testHasValueFormat() {
    // setup
    var spark    = createAnonymousLineSparkLine()
    let format   = " %.0f"
    
    // execute
    spark.currentValueFormat   = format
    
    // verify
    expect(spark.currentValueFormat).to(equal(format))
  }
  
  func testHasLabelColor() {
    // setup
    var spark     = createAnonymousLineSparkLine()
    let scarlet   = UIColor(red:0.99, green:0.14, blue:0.22, alpha:1.0)
    
    // execute
    spark.labelColor           = scarlet
    
    // verify
    expect(spark.labelColor).to(equal(scarlet))
  }
  
  func testHasPenWidth() {
    // setup
    var spark            = createAnonymousLineSparkLine()
    let width: CGFloat   = 1.0
    
    // execute
    spark.penWidth = width
    
    // verify
    expect(spark.penWidth).to(equal(width))
  }
  
  func testHasShowRangeOverlay() {
    // setup
    var spark     = createAnonymousLineSparkLine()
    
    // execute
    spark.showRangeOverlay = true
    
    // verify
    expect(spark.showRangeOverlay).to(beTrue())
  }
  
  // MARK: Plot space setup
  
  func testShouldComputeRanges() {
    // setup
    var spark = createSparklineWithData("glucose_data", label: "glucose")
    
    // execute
    spark.computeRanges(spark.dataValues!)
    
    // verify
    expect(spark.dataMaximum).to(beCloseTo(7.8))
    expect(spark.dataMinimum).to(beCloseTo(4.1))
  }
  
  func testHasValueForLabel() {
    // setup
    let spark = createSparklineWithData("glucose_data", label: "glucose")
    
    // execute
    let v = spark.valueForLabel()
    
    // verify
    expect(v).to(equal(7.0))
  }
  
  // MARK: Drawing

  func testShouldDraw_sparkline() {
    // setup
    let labelText = "glucose"
    var spark = createSparklineWithData("glucose_data", label: labelText)
    expect(spark.dataValues!.count).to(equal(30))
    let renderer = TestRenderer()
    spark.computeRanges(spark.dataValues!)
    
    // execute
    spark.draw( CGRectMake(0,0,280,40), renderer: renderer )
    
    // verify
    let whiskerCommands = ["setLineWidth(0.5)",
                           "setStroke(UIDeviceWhiteColorSpace 0 1)",
                           "beginPath()",
                           "moveTo(2.0, 21.4189186096191)",
                           "lineTo(8.95516760314039, 23.31081199646)",
                           "lineTo(15.9103352062808, 21.4189186096191)",
                           "lineTo(22.8655028094212, 23.31081199646)",
                           "lineTo(29.8206704125616, 27.094596862793)",
                           "lineTo(36.775838015702, 28.9864864349365)",
                           "lineTo(43.7310056188424, 30.8783760070801)",
                           "lineTo(50.6861732219828, 34.6621627807617)",
                           "lineTo(57.6413408251232, 37.5)",
                           "lineTo(64.5965084282635, 35.6081047058105)",
                           "lineTo(71.5516760314039, 33.7162170410156)",
                           "lineTo(78.5068436345443, 28.9864864349365)",
                           "lineTo(85.4620112376847, 20.472972869873)",
                           "lineTo(92.4171788408251, 21.4189186096191)",
                           "lineTo(99.3723464439655, 28.0405426025391)",
                           "lineTo(106.327514047106, 27.094596862793)",
                           "lineTo(113.282681650246, 23.31081199646)",
                           "lineTo(120.237849253387, 19.5270290374756)",
                           "lineTo(127.193016856527, 13.851354598999)",
                           "lineTo(134.148184459667, 8.17568016052246)",
                           "lineTo(141.103352062808, 2.5)",
                           "lineTo(148.058519665948, 6.28378295898438)",
                           "lineTo(155.013687269089, 10.067569732666)",
                           "lineTo(161.968854872229, 11.9594593048096)",
                           "lineTo(168.924022475369, 15.7432441711426)",
                           "lineTo(175.87919007851, 19.5270290374756)",
                           "lineTo(182.83435768165, 15.7432441711426)",
                           "lineTo(189.789525284791, 11.9594593048096)",
                           "lineTo(196.744692887931, 8.17568016052246)",
                           "lineTo(203.699860491071, 10.067569732666)",
                           "strokePath()",
                           "setFill(UIDeviceRGBColorSpace 0 0 1 1)",
                           "fillEllipse((199.699860491071, 6.06756973266602, 8.0, 8.0))",
                           "saveState()",
                           "setFill(UIDeviceRGBColorSpace 0 0 1 1)",
                           "restoreState()"]
    
    expect(renderer.commands.count).to(equal(39))
    assertThatCommandsEqual( renderer.commands, expected: whiskerCommands )
  }
  
}



//
//  SparkLinePlotter.swift
//  sparklines
//
//  Created by Jim Holt on 8/27/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

let GRAPH_X_BORDER:                CGFloat = 2.0                                               // horizontal border width for the graph line (in points)
let GRAPH_Y_BORDER:                CGFloat = 2.0                                               // vertical border width for the graph line (in points)
let DEFAULT_LABEL_COL:             UIColor = UIColor.darkGray                           // default label text colour
let DEFAULT_CURRENTVALUE_COL:      UIColor = UIColor.blue                               // default current value colour (including the anchor marker)
let DEFAULT_OVERLAY_COL:           UIColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1.0)  // default overlay colour (light gray)
let DEFAULT_HIGHLIGHT_OVERLAY_COL: UIColor = UIColor(red:1.0, green:0.85, blue:0.8, alpha:1.0) // default overlay colour (Cinderella)
let PEN_COL:                       UIColor = UIColor.black                              // default graph line colour (black)
let DEFAULT_GRAPH_PEN_WIDTH:       CGFloat = 1.0

let MAX_TEXT_FRAC:                 CGFloat = 0.5     // maximum fraction of view to give to the textual part
var LABEL_FONT:                    String  = "Helvetica"
var DEFAULT_FONT_SIZE:             CGFloat = 12.0    // we'll try to use this font size
var MIN_FONT_SIZE:                 CGFloat = 10.0    // this is the minimum font size, after that, we'll truncate

// WhiskerSparkLine

let TIME_PEN_WIDTH:           CGFloat = 1.0
let DEFAULT_TICK_PEN_WIDTH:   CGFloat = 4.0
var TICK_PEN_WIDTH:           CGFloat = DEFAULT_TICK_PEN_WIDTH    // pen width for the tick line (in *pixels*)
let MAX_WHISKER_HEIGHT:       Float   = 8.0


protocol SparkLinePlotter {
  
  var GRAPH_PEN_WIDTH:    CGFloat    {get}     // pen width for the line (in *pixels*)
  
  var dataValues:         [NSNumber]? {get set}
  var labelText:          String?     {get set}
  var labelFont:          String      {get set}
  var currentValueFormat: String      {get set}
  
  var penColor:           UIColor     {get set}
  var penWidth:           CGFloat     {get set}

  var dataMinimum:        NSNumber? {get set}
  var dataMaximum:        NSNumber? {get set}
  
  
  mutating func initialize(_ data: [NSNumber], label: String)
  mutating func computeRanges(_ dataValues: [NSNumber])
  func computeMaxMin(_ values: [NSNumber]) -> (max: NSNumber?, min: NSNumber?)
  mutating func drawSparkLine(_ plotSpace: inout PlotSpace, dataValues: [NSNumber], renderer: Renderer )
  mutating func draw( _ bounds: CGRect, renderer: Renderer )
  func createSparkLabel(_ labelText: String, value: Float, bounds: CGRect, values: [NSNumber]) -> SparkLineLabel
  func drawLabelAndValue( _ sparkLabel: SparkLineLabel, renderer: Renderer )
  func valueForLabel() -> Float
  func xInc(_ values: [NSNumber], penWidth: CGFloat, plotSpace: PlotSpace) -> CGFloat
  func yInc(_ penWidth: CGFloat, plotSpace: PlotSpace) -> Float
  func selectPenWidth(_ penWidth: CGFloat, scaleFactor: CGFloat, renderer: Renderer)
  func selectPenColor(_ penColor: UIColor, renderer: Renderer)
  func drawValues( _ values: [NSNumber], plotSpace: inout PlotSpace, xInc: CGFloat, yInc: Float, renderer: Renderer )
  func validateYPos(_ value: AnyObject, yInc: Float, index: Int, plotSpace: PlotSpace) -> CGFloat
  func yPlotValue(_ maxHeight: Float, yInc: Float, val: Float, offset: Float, penWidth: Float) -> CGFloat
}

extension SparkLinePlotter {
  
  var GRAPH_PEN_WIDTH:   CGFloat  {return DEFAULT_GRAPH_PEN_WIDTH}    // pen width for the line (in *pixels*)
  
  // Calculates the min and max values (for auto-scaling) for array of NSNumber
  func computeMaxMin(_ values: [NSNumber]) -> (max: NSNumber?, min: NSNumber?) {
    var min: NSNumber?
    var max: NSNumber?
    
    let numData = values.count
    
    /// special cases first
    if numData == 0 {
      min = nil
      max = nil
      
    } else if numData == 1 {
      min = values.last
      max = values.last
      
    } else {
      min = values.first!
      max = min
      
      // extract the min and max values (ignore any non-NSNumber objects)
      for (_, value) in values.enumerated() {
        if value.isKind(of: NSNumber.self) {
          let val = value.floatValue
          if val < min!.floatValue {
            min = val as NSNumber?
          } else if val > max!.floatValue {
            max = val as NSNumber?
          }
        }
      }               // for
    }                 // end else
    
    return (max, min)
  }
  
  mutating func draw( _ bounds: CGRect, renderer: Renderer ) {
    
    // Template method for drawning the sparkline

    // Create the label (includes calculating the text width)
    // -createSparkLabel is a seam for selecting label order (value+text vs text+value)
    
    let labelValue = valueForLabel()
    var sparkLabel = createSparkLabel( labelText!,
                                       value: labelValue,
                                       bounds: bounds,
                                       values: dataValues! )

    // Create the plot space for the sparkline
    
    var plotSpace = PlotSpace(bounds: bounds,
                              dataMinimum: dataMinimum!.floatValue,
                              dataMaximum: dataMaximum!.floatValue)

    // Save the label size in the plot space
    // Depends on having formattedGraphText
    
    plotSpace.textWidth = sparkLabel.textSize.width
    
    // Draw the graph
    
    drawSparkLine( &plotSpace, dataValues: dataValues!, renderer: renderer)
    
    // And then the label
    // -whiskerTextStartX needed to left justify the whisker label
    
    let plotWidth = plotSpace.xInc!*CGFloat(plotSpace.numberOfPoints!)
    sparkLabel.whiskerTextStartX =
      GRAPH_X_BORDER + plotSpace.xOffsetToCenter + plotWidth
    
    drawLabelAndValue(sparkLabel, renderer: renderer)
  }
  
  func yInc(_ penWidth: CGFloat, plotSpace: PlotSpace) -> Float {
    // Y scale is auto-zoomed to specified limits (allowing for pen width)
    
    return (Float(plotSpace.sparkHeight) - Float(penWidth)) / (plotSpace.graphMax - plotSpace.graphMin)
  }
  
  func selectPenWidth(_ penWidth: CGFloat, scaleFactor: CGFloat, renderer: Renderer) {
    // ensure the pen is a suitable width for the device we are on (i.e. we use *pixels* and not points)
    if penWidth != 0.0 {
      renderer.setLineWidth( penWidth / scaleFactor )
    } else {
      renderer.setLineWidth( GRAPH_PEN_WIDTH / scaleFactor )
    }
  }
  
  func selectPenColor(_ penColor: UIColor, renderer: Renderer) {
    // Customisation to allow pencolour changes
    if penColor != PEN_COL {
      renderer.setStroke( penColor )
    } else {
      renderer.setStroke( PEN_COL )
    }
  }
  
  func drawValues( _ values: [NSNumber], plotSpace: inout PlotSpace, xInc: CGFloat, yInc: Float, renderer: Renderer ) {
    renderer.beginPath()
    
    // iterate over the data items, plotting the graph path
    for (index, value) in values.enumerated() {
      
      let xpos: CGFloat = xInc * CGFloat(index) + GRAPH_X_BORDER
      let ypos: CGFloat = validateYPos( value, yInc: yInc, index: index, plotSpace: plotSpace )
      
      if (index > 0) {
        renderer.lineTo( CGPoint(x: xpos, y: ypos) )
      } else {
        renderer.moveTo( CGPoint(x: xpos, y: ypos) )
      }
    }
    
    // draw the graph line (path)
    renderer.strokePath()
  }
  
}



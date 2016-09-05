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
let DEFAULT_LABEL_COL:             UIColor = UIColor.darkGrayColor()                           // default label text colour
let DEFAULT_CURRENTVALUE_COL:      UIColor = UIColor.blueColor()                               // default current value colour (including the anchor marker)
let DEFAULT_OVERLAY_COL:           UIColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1.0)  // default overlay colour (light gray)
let DEFAULT_HIGHLIGHT_OVERLAY_COL: UIColor = UIColor(red:1.0, green:0.85, blue:0.8, alpha:1.0)  // default overlay colour (Cinderella)
let PEN_COL:                       UIColor = UIColor.blackColor()                              // default graph line colour (black)
let DEFAULT_GRAPH_PEN_WIDTH:       CGFloat = 1.0

let MAX_TEXT_FRAC:                 CGFloat = 0.5     // maximum fraction of view to give to the textual part
var LABEL_FONT:                    String  = "Helvetica"
var DEFAULT_FONT_SIZE:             CGFloat = 12.0    // we'll try to use this font size
var MIN_FONT_SIZE:                 CGFloat = 10.0    // this is the minimum font size, after that, we'll truncate

// WhiskerSparkLine

let TIME_PEN_WIDTH:           CGFloat = 1.0
let DEFAULT_TICK_PEN_WIDTH:   CGFloat = 4.0
var TICK_PEN_WIDTH:           CGFloat = DEFAULT_TICK_PEN_WIDTH    // pen width for the graph line (in *pixels*)
let MAX_WHISKER_HEIGHT:       Float   = 8.0


protocol SparkLinePlotter: class {
  
  var GRAPH_PEN_WIDTH:    CGFloat    {get}     // pen width for the graph line (in *pixels*)
  
  var dataValues:         [NSNumber]? {get set}
  var labelText:          String?     {get set}
  var labelFont:          String      {get set}
  var currentValueFormat: String      {get set}
  
  var penColor:           UIColor     {get set}
  var penWidth:           CGFloat     {get set}

  var dataMinimum:        NSNumber? {get set}
  var dataMaximum:        NSNumber? {get set}
  
  init(data: [NSNumber], frame: CGRect, label: String)
  
  func awakeFromNib()
  func initialize(data: [NSNumber], label: String)
  func computeRanges(dataValues: [NSNumber])
  func configureView()
  func computeMaxMin(values: [NSNumber]) -> (max: NSNumber?, min: NSNumber?)
  func drawRect(rect: CGRect)
  func drawGraphInContext(inout plotSpace: PlotSpace, dataValues: [NSNumber], context: CGContextRef )
  func drawSparkline( labelText: String, bounds: CGRect, dataMinimum: Float, dataMaximum: Float, dataValues: [NSNumber], context: CGContextRef )
  func createSparkLabel(labelText: String, value: Float, bounds: CGRect, values: [NSNumber]) -> SparkLineLabel
  func formattedGraphText( graphText: String, formattedValue: String, showValue: Bool) -> String
  func formattedLabelValue( currentValue: Float ) -> String
  func drawLabelAndValue( sparkLabel: SparkLineLabel, context: CGContextRef )
  func valueForLabel() -> Float
  func xInc(values: [NSNumber], penWidth: CGFloat, plotSpace: PlotSpace) -> CGFloat
  func yInc(penWidth: CGFloat, plotSpace: PlotSpace) -> Float
  func selectPenWidth(penWidth: CGFloat, context: CGContextRef)
  func selectPenColor(penColor: UIColor)
  func drawValues( values: [NSNumber], inout plotSpace: PlotSpace, xInc: CGFloat, yInc: Float, context: CGContextRef )
  func validateYPos(value: AnyObject, yInc: Float, index: Int, plotSpace: PlotSpace) -> CGFloat
  func yPlotValue(maxHeight: Float, yInc: Float, val: Float, offset: Float, penWidth: Float) -> CGFloat
}

extension SparkLinePlotter where Self: UIView {
  
  var GRAPH_PEN_WIDTH:   CGFloat    {return DEFAULT_GRAPH_PEN_WIDTH}    // pen width for the graph line (in *pixels*)
  
  func awakeFromNib() {
    configureView()
  }
  
  func computeRanges(dataValues: [NSNumber]) {
    let computedValues = computeMaxMin( dataValues )
    dataMaximum = computedValues.max
    dataMinimum = computedValues.min
  }
  
  // configures the defaults (used in init or when waking from a nib)
  func configureView() {
    
    // ensure we redraw correctly when resized
    self.contentMode = UIViewContentMode.Redraw
    
    // and we have a nice rounded shape...
    self.layer.masksToBounds = true
    self.layer.cornerRadius = 5.0
  }
  
  // Calculates the min and max values (for auto-scaling)
  func computeMaxMin(values: [NSNumber]) -> (max: NSNumber?, min: NSNumber?) {
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
      for (_, value) in values.enumerate() {
        if value.isKindOfClass(NSNumber) {
          let val = value.floatValue
          if val < min!.floatValue {
            min = val
          } else if val > max!.floatValue {
            max = val
          }
        }
      }               // for
    }                 // end if
    
    return (max, min)
  }
  
  func drawSparkline( text: String, bounds: CGRect, dataMinimum: Float, dataMaximum: Float, dataValues: [NSNumber], context: CGContextRef ) {
    
    // Template method for drawning the sparkline

    // Create the label
    
    let labelValue = valueForLabel()
    var sparkLabel = createSparkLabel( text,
                                       value: labelValue,
                                       bounds: bounds,
                                       values: dataValues )

    // Format the label and calculate text width
    
    sparkLabel.formattedGraphText = formattedGraphText( sparkLabel.graphText,
                                                        formattedValue:sparkLabel.formattedLabelValue,
                                                        showValue: true )

    // Create the plot space for the sparkline
    
    var plotSpace = PlotSpace(bounds: bounds,
                              dataMinimum: dataMinimum,
                              dataMaximum: dataMaximum)

    // Save the label size in the plot space
    // Depends on having formattedGraphText
    
    plotSpace.textWidth = sparkLabel.textSize.width
    
    // Draw the graph
    
    drawGraphInContext( &plotSpace, dataValues: dataValues, context: context)
    
    // And then the label
    // whiskerTextStartX needed to left justify the whisker label
    
    sparkLabel.whiskerTextStartX = GRAPH_X_BORDER +
      plotSpace.xInc!*CGFloat(plotSpace.numberOfPoints!) + plotSpace.xOffsetToCenter
    
    drawLabelAndValue(sparkLabel, context: context)
  }
  
  func yInc(penWidth: CGFloat, plotSpace: PlotSpace) -> Float {
    // Y scale is auto-zoomed to specified limits (allowing for pen width)
    
    return (Float(plotSpace.sparkHeight) - Float(penWidth)) / (plotSpace.graphMax - plotSpace.graphMin)
  }
  
  func selectPenWidth(penWidth: CGFloat, context: CGContextRef) {
    // ensure the pen is a suitable width for the device we are on (i.e. we use *pixels* and not points)
    let csf = self.contentScaleFactor
    if penWidth != 0.0 {
      CGContextSetLineWidth(context, penWidth / csf)
    } else {
      CGContextSetLineWidth(context, GRAPH_PEN_WIDTH / csf)
    }
  }
  
  func selectPenColor(penColor: UIColor) {
    // Customisation to allow pencolour changes
    if penColor != PEN_COL {
      penColor.setStroke()
    } else {
      PEN_COL.setStroke()
    }
  }
  
  func formattedLabelValue( currentValue: Float ) -> String {
    
    let result = " ".stringByAppendingFormat(currentValueFormat, currentValue )
    
    return result
  }

  func drawValues( values: [NSNumber], inout plotSpace: PlotSpace, xInc: CGFloat, yInc: Float, context: CGContextRef ) {
    CGContextBeginPath(context)
    
    // iterate over the data items, plotting the graph path
    for (index, value) in values.enumerate() {
      
      let xpos: CGFloat = xInc * CGFloat(index) + GRAPH_X_BORDER
      let ypos: CGFloat = validateYPos( value, yInc: yInc, index: index, plotSpace: plotSpace )
      
      if (index > 0) {
        CGContextAddLineToPoint(context, xpos, ypos)
      } else {
        CGContextMoveToPoint(context, xpos, ypos)
      }
    }
    
    // draw the graph line (path)
    CGContextStrokePath(context)
  }
  
}



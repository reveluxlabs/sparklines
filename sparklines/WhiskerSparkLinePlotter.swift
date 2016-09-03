//
//  WhiskerSparkLinePlotter.swift
//  sparklines
//
//  Created by Jim Holt on 9/2/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

protocol WhiskerSparkLinePlotter: SparkLinePlotter {
  var dataSource:              WhiskerSparkLineDataSource? {get set}
  var showLabel:               Bool     {get set}
  var labelColor:              UIColor  {get set}
  var xIncrement:              CGFloat  {get set}
  var whiskerColor:            UIColor  {get set}
  var highlightedWhiskerColor: UIColor  {get set}
  var tickWidth:               CGFloat  {get set}
  var longestRun:              Int?     {get set}
  var centerSparkLine:         Bool     {get set}
  
  func pointCount( dataValues: [NSNumber] ) -> Int
  func xOffsetToCenterWhiskers(dataValues: [NSNumber], xInc: CGFloat ) -> CGFloat
  func selectTickPenWidth( tickWidth: CGFloat, context: CGContextRef )
  func selectTimePenWidth( timeWidth: CGFloat, context: CGContextRef )
  func drawWhiskerAtXpos( xpos: CGFloat, ypos: CGFloat, centerY: CGFloat, context: CGContextRef)
  func drawTickAtXpos( xpos: CGFloat,  xinc: CGFloat, tickColor: UIColor, plotSpace: PlotSpace, context: CGContextRef)
  func drawAxisToXpos( xpos:CGFloat, xOffset: CGFloat, ypos:CGFloat, centerY: CGFloat, context: CGContextRef )
}

extension WhiskerSparkLinePlotter where Self: UIView {
  
  func initialize(data: [NSNumber], label: String) {
    dataValues = data
    computeRanges(dataValues!)
    configureView()
    self.setNeedsDisplay()
  }
  
  func drawGraphInContext(inout plotSpace: PlotSpace, dataValues: [NSNumber], context: CGContextRef ) {
    
    //    showRangeOverlay = disableOverlayIfLimitsInconsistent( showRangeOverlay, upperLimit: rangeOverlayUpperLimit , lowerLimit: rangeOverlayLowerLimit )
    //
    //    configureOverlay( &plotSpace, upperLimit: rangeOverlayUpperLimit , lowerLimit: rangeOverlayLowerLimit )
    //
    //    drawOverlayIfEnabled( &plotSpace, context: context )
    
    // For whiskers, X scale is set to a fixed value
    // dataValues may be empty if we are using SparkLineDataSource
    
    let xinc = xInc( dataValues, penWidth: penWidth, plotSpace: plotSpace)
    
    plotSpace.xInc = xinc
    plotSpace.numberOfPoints = pointCount( dataValues )
    
    // Y scale is auto-zoomed to specified limits (allowing for pen width)
    
    let yinc = yInc(penWidth, plotSpace: plotSpace)
    
    selectPenWidth(penWidth, context: context)
    
    selectPenColor(penColor)
    
    // Needed for drawValues
    if centerSparkLine {
       plotSpace.xOffsetToCenter = xOffsetToCenterWhiskers( dataValues, xInc: xinc )
    }

    drawValues( dataValues, plotSpace: &plotSpace, xInc: xinc, yInc: yinc, context: context)
  }
  
  func pointCount( dataValues: [NSNumber] ) -> Int {
    var numberOfPoints: Int
    if let ds = dataSource {
      numberOfPoints = ds.numberOfDataPoints(self)
      
    } else {
      numberOfPoints = dataValues.count
    }
    return numberOfPoints
  }
  
  func xOffsetToCenterWhiskers(dataValues: [NSNumber], xInc: CGFloat ) -> CGFloat {
    var xOffsetToCenter: CGFloat?
    
    let numberOfPoints = pointCount(dataValues)
    
    let viewWidth = self.bounds.size.width
    let graphWidth = xInc * CGFloat(numberOfPoints)
    let delta = viewWidth - graphWidth
    xOffsetToCenter = delta/2.0
    
    if floor(xOffsetToCenter!)*2.0 == delta {
      // even
      xOffsetToCenter! += 0.5
    }
    
    if xOffsetToCenter < 0.0 {
      print("Warning: graph width \(graphWidth) exceeds view width \(viewWidth)")
    }
    
    return xOffsetToCenter!
  }
  
  func createSparkLabel(labelText: String, value: Float, bounds: CGRect, values: [NSNumber]) -> SparkLineLabel {
    let sparkLabel = SparkLineLabel(bounds: self.bounds,
                                    count: values.count,
                                    text: labelText,
                                    font: labelFont,
                                    value: value,
                                    showValue: showLabel,
                                    valueColor: labelColor,
                                    valueFormat: currentValueFormat)
    return sparkLabel
  }
  
  func formattedGraphText( graphText: String, formattedValue: String, showValue: Bool) -> String {
    
    var graphText = labelText == nil ? "not set" : String(UTF8String: labelText!)!
    
    let formattedValue = formattedLabelValue(Float(longestRun!))
    
    if showLabel {
      graphText = formattedValue + " " + graphText
    }
    
    return graphText
  }
  
  func drawLabelAndValue( sparkLabel: SparkLineLabel, context: CGContextRef ) {
    if showLabel {
      
      var attrs = sparkLabel.attributes
      attrs![NSForegroundColorAttributeName] = labelColor
      
      var textStart  = CGPointMake(sparkLabel.whiskerTextStartX!, sparkLabel.textStartY)
      
      sparkLabel.formattedLabelValue.drawAtPoint(textStart, withAttributes:attrs)
      
      textStart = CGPointMake(sparkLabel.whiskerTextStartX! + sparkLabel.valueDrawnSize.width, sparkLabel.textStartY)
      
      (" " + labelText!).drawAtPoint(textStart, withAttributes:attrs)
    }
  }
  
  func valueForLabel() -> Float {
    return Float(longestRun!)
  }
  
  func selectTickPenWidth( tickWidth: CGFloat, context: CGContextRef ) {
    // Ensure the tick pen is a suitable width for the device we are on (i.e. we use *pixels* and not points)
    if (tickWidth != 0.0) {
      CGContextSetLineWidth(context, tickWidth / self.contentScaleFactor);
    } else {
      CGContextSetLineWidth(context, TICK_PEN_WIDTH / self.contentScaleFactor);
    }
  }
  
  func selectTimePenWidth( timeWidth: CGFloat, context: CGContextRef) {
    // Ensure the tick pen is a suitable width for the device we are on (i.e. we use *pixels* and not points)
    if (timeWidth != 0.0) {
      CGContextSetLineWidth(context, timeWidth / self.contentScaleFactor);
    } else {
      CGContextSetLineWidth(context, TIME_PEN_WIDTH / self.contentScaleFactor);
    }
  }
  
  func xInc( _: [NSNumber], penWidth: CGFloat, plotSpace _: PlotSpace) -> CGFloat {
    // X scale is set to fixed value from whisker view
    let xi = xIncrement
    return xi
  }
  
  func drawWhiskerAtXpos( xpos: CGFloat, ypos: CGFloat, centerY: CGFloat, context: CGContextRef) {
    //   Draw a whisker from (xpos,centerY) to (xpos, ypos) in context.
    
    selectPenWidth(penWidth, context: context)
    CGContextMoveToPoint(context, xpos, centerY)
    CGContextAddLineToPoint(context, xpos, ypos)
    CGContextClosePath(context)
    CGContextStrokePath(context)
  }
  
  func drawTickAtXpos( xpos: CGFloat,  xinc: CGFloat, tickColor: UIColor, plotSpace: PlotSpace, context: CGContextRef) {
    // Draw a tick of color tickColor from (xpos-xinc, 0.0) to (xpos-xinc, self.fullHeight) in context.
    let xposGrid = xpos - 0.5 * xinc
    tickColor.setStroke()
    selectTickPenWidth(tickWidth, context: context)
    
    CGContextMoveToPoint(context, xposGrid, 0.0);
    CGContextAddLineToPoint(context, xposGrid, plotSpace.fullHeight);
    CGContextClosePath(context);
    
    // draw the tick
    CGContextStrokePath(context);
  }
  
  func drawAxisToXpos( xpos:CGFloat, xOffset: CGFloat, ypos:CGFloat, centerY: CGFloat, context: CGContextRef ) {
    
    selectPenWidth(penWidth, context: context)
    selectPenColor(penColor)
    
    CGContextMoveToPoint(context, 0.0 + GRAPH_Y_BORDER + xOffset, centerY);
    CGContextAddLineToPoint(context, xpos+0.5 , centerY);
    CGContextClosePath(context);
    
    // draw the graph line (path)
    CGContextStrokePath(context);
  }
  
  func validateYPos(value: AnyObject, yInc: Float, index: Int, plotSpace: PlotSpace) -> CGFloat {
    // Hook method
    var ypos: CGFloat = 0.0
    
    // warning and zero value for any non-NSNumber objects
    if value.isKindOfClass(NSNumber) {
      ypos = yPlotValue(Float(plotSpace.fullHeight),
                        yInc: Float(yInc),
                        val: value.floatValue,
                        offset: Float(plotSpace.fullHeight/2),
                        penWidth: Float(penWidth))
      
    } else {
      ypos = yPlotValue(Float(plotSpace.fullHeight),
                        yInc: Float(yInc),
                        val: 0.0,
                        offset: Float(plotSpace.fullHeight/2),
                        penWidth: Float(penWidth))
    }
    return ypos
  }
  
  @inline(__always)
  func yPlotValue(maxHeight: Float, yInc: Float, val: Float, offset: Float, penWidth: Float) -> CGFloat {
    // returns the Y plot value, given the limitations we have
    // yInc unused but needed in signature
    // offset has centerY
    var result: Float
    
    result = maxHeight / 2.0
    
    if val == 1.0 {
      let rawDeltaY = maxHeight - Float(GRAPH_Y_BORDER)
      let deltaY = min(rawDeltaY - offset, MAX_WHISKER_HEIGHT)
      result = deltaY + offset
    } else if (val == -1.0) {
      let rawDeltaY = 0.0 + Float(GRAPH_Y_BORDER)
      let deltaY = min(offset - rawDeltaY, MAX_WHISKER_HEIGHT)
      result = offset - deltaY
    }
    result = maxHeight - result    // flip, ios y coordinate space increases down
    
    return CGFloat(result)
  }
  
}
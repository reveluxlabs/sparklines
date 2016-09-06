//
//  LineSparkLinePlotter.swift
//  sparklines
//
//  Created by Jim Holt on 9/2/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

protocol LineSparkLinePlotter: SparkLinePlotter {
  
  var MARKER_MIN_SIZE:           CGFloat    {get}     // maximum size of the anchor marker we'll use (in points)
  var DEF_MARKER_SIZE_FRAC:      CGFloat    {get}     // default fraction of the view height we'll use for the anchor marker
  var MARKER_MAX_SIZE:           CGFloat    {get}     // maximum size of the anchor marker we'll use (in points)
  var CONSTANT_GRAPH_BUFFER:     Float      {get}     // fraction to move the graph limits when min = max
  
  var dataSource:                SparkLineDataSource? {get set}
  var showCurrentValue:          Bool        {get set}
  var currentValueColor:         UIColor     {get set}
  var showRangeOverlay:          Bool        {get set}
  var rangeOverlayColor:         UIColor     {get set}
  
  var rangeOverlayLowerLimit:    NSNumber? {get set}
  var rangeOverlayUpperLimit:    NSNumber? {get set}
  
  func disableOverlayIfLimitsInconsistent( showOverlay: Bool, upperLimit: NSNumber?, lowerLimit: NSNumber? ) -> Bool
  func configureOverlay( inout plotSpace: PlotSpace, upperLimit: NSNumber?, lowerLimit: NSNumber? )
  func drawOverlayIfEnabled( inout plotSpace: PlotSpace, context: CGContextRef)
  func drawValueMarker(values: [NSNumber], inout plotSpace: PlotSpace, xInc: CGFloat, yInc: Float, context: CGContextRef)
}

extension LineSparkLinePlotter where Self: UIView {
  
  var MARKER_MIN_SIZE:       CGFloat    {return 4.0}     // maximum size of the anchor marker we'll use (in points)
  var DEF_MARKER_SIZE_FRAC:  CGFloat    {return 0.2}     // default fraction of the view height we'll use for the anchor marker
  var MARKER_MAX_SIZE:       CGFloat    {return 8.0}     // maximum size of the anchor marker we'll use (in points)
  var CONSTANT_GRAPH_BUFFER: Float      {return 0.1}     // fraction to move the graph limits when min = max
  
  func initialize(data: [NSNumber], label: String) {
    dataValues = data
    labelText = label
    computeRanges(dataValues!)
    configureView()
    self.setNeedsDisplay()
  }
  
  func computeRanges(dataValues: [NSNumber]) {
    let computedValues = computeMaxMin( dataValues )
    dataMaximum = computedValues.max
    dataMinimum = computedValues.min
    rangeOverlayUpperLimit = dataMaximum
    rangeOverlayLowerLimit = dataMinimum
  }
  
  func drawGraphInContext(inout plotSpace: PlotSpace, dataValues: [NSNumber], context: CGContextRef ) {
    
    showRangeOverlay = disableOverlayIfLimitsInconsistent( showRangeOverlay, upperLimit: rangeOverlayUpperLimit , lowerLimit: rangeOverlayLowerLimit )
    
    configureOverlay( &plotSpace, upperLimit: rangeOverlayUpperLimit , lowerLimit: rangeOverlayLowerLimit )
    
    drawOverlayIfEnabled( &plotSpace, context: context )
    
    // X scale is set to show all values
    
    let xinc = xInc( dataValues, penWidth: penWidth, plotSpace: plotSpace)
    
    // Y scale is auto-zoomed to specified limits (allowing for pen width)
    
    let yinc = yInc(penWidth, plotSpace: plotSpace)
    
    selectPenWidth(penWidth, context: context)
    
    selectPenColor(penColor)
    
    drawValues( dataValues, plotSpace: &plotSpace, xInc: xinc, yInc: yinc, context: context)
    
    // draw the value marker circle, if requested
    
    if showCurrentValue {
      drawValueMarker( dataValues, plotSpace: &plotSpace, xInc: xinc, yInc: yinc, context: context )
    }
  }
  
  func createSparkLabel(labelText: String, value: Float, bounds: CGRect, values: [NSNumber]) -> SparkLineLabel {
    let sparkLabel = SparkLineLabel(bounds: self.bounds,
                                    count: values.count,
                                    text: labelText,
                                    font: labelFont,
                                    value: value,
                                    showValue: showCurrentValue,
                                    valueColor: currentValueColor,
                                    valueFormat: currentValueFormat)
    return sparkLabel
  }
  
  func formattedGraphText( graphText: String, formattedValue: String, showValue: Bool) -> String {
    
    var graphText = labelText == nil ? "not set" : String(UTF8String: labelText!)!
    
    let formattedValue = formattedLabelValue( dataValues!.last!.floatValue )
    
    if showCurrentValue {
      graphText = graphText + formattedValue
    }
    
    return graphText
  }
  
  func drawLabelAndValue( sparkLabel: SparkLineLabel, context: CGContextRef ) {
    // first we draw the label using the specified font
    var textStart  = CGPointMake(sparkLabel.textStartX, sparkLabel.textStartY)
    
    labelText!.drawAtPoint(textStart, withAttributes:sparkLabel.attributes)
    
    // conditionally draw the current value in the chosen colour
    if showCurrentValue {
      CGContextSaveGState(context)
      currentValueColor.setFill()
      textStart = CGPointMake(sparkLabel.textStartX + sparkLabel.labelDrawnSize.width, sparkLabel.textStartY)
      
      sparkLabel.formattedLabelValue.drawAtPoint(textStart, withAttributes:sparkLabel.attributes)
      
      CGContextRestoreGState(context)
    }
  }
  
  func valueForLabel() -> Float {
    return dataValues!.last!.floatValue
  }
  
  func disableOverlayIfLimitsInconsistent( showOverlay: Bool, upperLimit: NSNumber?, lowerLimit: NSNumber? ) -> Bool {
    var result = showOverlay
    // disable overlay if the upper limit is at or below the lower limit
    if showOverlay &&
      upperLimit != nil &&
      lowerLimit != nil &&
      upperLimit!.floatValue <= lowerLimit!.floatValue {
      result = false
    }
    
    return result
  }
  
  func configureOverlay( inout plotSpace: PlotSpace, upperLimit: NSNumber?, lowerLimit: NSNumber? ) {
    // upper scale limit will be the maximum of (defined) overlay and data maxima
    if (upperLimit != nil) {
      let rangeUpper = upperLimit!.floatValue
      if (rangeUpper > plotSpace.graphMax) {
        plotSpace.graphMax = rangeUpper
      }
    }
    
    // lower scale limit will be the minimum of (defined) overlay and data minima
    if (lowerLimit != nil) {
      let rangeLower = lowerLimit!.floatValue
      if (rangeLower < plotSpace.graphMin) {
        plotSpace.graphMin = rangeLower
      }
    }
    
    // special case if min = max, push the limits 10% further
    if (plotSpace.graphMin == plotSpace.graphMax) {
      plotSpace.graphMin *= 1.0 - CONSTANT_GRAPH_BUFFER
      plotSpace.graphMax *= 1.0 + CONSTANT_GRAPH_BUFFER
    }
  }
  
  func drawOverlayIfEnabled( inout plotSpace: PlotSpace, context: CGContextRef) {
    
    // default: undefined overlay limit means "no limit", so overlay will extend to view border
    
    var overlayOrigin: CGFloat = 0.0
    var overlayHeight: CGFloat = plotSpace.fullHeight
    
    // show the graph overlay if (still) enabled
    if showRangeOverlay {
      
      // set the graph location of the overlay upper and lower limits, if defined
      
      if rangeOverlayUpperLimit != nil {
        overlayOrigin = yPlotValue(Float(plotSpace.fullHeight),
                                   yInc: Float(plotSpace.sparkHeight) / (plotSpace.graphMax - plotSpace.graphMin),
                                   val: rangeOverlayUpperLimit!.floatValue,
                                   offset:  plotSpace.graphMin,
                                   penWidth:  Float(penWidth))
      }
      if rangeOverlayLowerLimit != nil {
        let lowerY = yPlotValue(Float(plotSpace.fullHeight),
                                yInc: Float(plotSpace.sparkHeight) / (plotSpace.graphMax - plotSpace.graphMin),
                                val: rangeOverlayLowerLimit!.floatValue,
                                offset:  plotSpace.graphMin,
                                penWidth:  Float(penWidth))
        overlayHeight = CGFloat(lowerY) - overlayOrigin
      }
      
      // draw the overlay
      
      rangeOverlayColor.setFill()
      let overlayRect = CGRectMake(GRAPH_X_BORDER, CGFloat(overlayOrigin), plotSpace.sparkWidth, overlayHeight)
      CGContextFillRect(context, overlayRect)
    }
  }
  
  func xInc(values: [NSNumber], penWidth: CGFloat, plotSpace: PlotSpace) -> CGFloat {
    // X scale is set to show all values
    
    return plotSpace.sparkWidth / CGFloat(values.count - 1)
  }
  
  func drawValueMarker(values: [NSNumber], inout plotSpace: PlotSpace, xInc: CGFloat, yInc: Float, context: CGContextRef) {
    let markX = xInc * CGFloat(values.count-1) + GRAPH_X_BORDER
    let markY = yPlotValue(Float(plotSpace.fullHeight),
                           yInc: yInc,
                           val: values.last!.floatValue,
                           offset: plotSpace.graphMin,
                           penWidth: Float(penWidth))
    
    // calculate the accent marker size, with limits
    var markSize = plotSpace.fullHeight * DEF_MARKER_SIZE_FRAC
    if (markSize < MARKER_MIN_SIZE) {
      markSize = MARKER_MIN_SIZE
    } else if markSize > MARKER_MAX_SIZE {
      markSize = MARKER_MAX_SIZE
    }
    
    let markRect = CGRectMake(markX - (markSize/2.0), markY - (markSize/2.0), markSize, markSize)
    currentValueColor.setFill()
    CGContextFillEllipseInRect(context, markRect)
  }
  
  func validateYPos(value: AnyObject, yInc: Float, index: Int, plotSpace: PlotSpace) -> CGFloat {
    // Hook method
    var ypos: CGFloat = 0.0
    
    // warning and zero value for any non-NSNumber objects
    if value.isKindOfClass(NSNumber) {
      ypos = yPlotValue(Float(plotSpace.fullHeight),
                        yInc: Float(yInc),
                        val: value.floatValue,
                        offset: plotSpace.graphMin,
                        penWidth: Float(penWidth))
      
    } else {
      ypos = yPlotValue(Float(plotSpace.fullHeight),
                        yInc: Float(yInc),
                        val: 0.0,
                        offset: plotSpace.graphMin,
                        penWidth: Float(penWidth))
    }
    return ypos
  }
  
  @inline(__always)
  func yPlotValue(maxHeight: Float, yInc: Float, val: Float, offset: Float, penWidth: Float) -> CGFloat {
    let y = yInc * (val - offset)
    let pen = penWidth / 2.0
    let height = y + Float(GRAPH_Y_BORDER) + pen
    let ypv = maxHeight - height
    
    return CGFloat(ypv)
  }
  
}

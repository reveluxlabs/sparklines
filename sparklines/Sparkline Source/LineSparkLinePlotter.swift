//
//  LineSparkLinePlotter.swift
//  sparklines
//
//  Created by Jim Holt on 9/2/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

protocol LineSparkLinePlotter: SparkLinePlotter {
  
  var MARKER_MIN_SIZE:           CGFloat    {get}     // maximum size of the anchor marker (in points)
  var DEF_MARKER_SIZE_FRAC:      CGFloat    {get}     // default fraction of the view height for the anchor marker
  var MARKER_MAX_SIZE:           CGFloat    {get}     // maximum size of the anchor marker (in points)
  var CONSTANT_GRAPH_BUFFER:     Float      {get}     // fraction to move the graph limits when min = max
  
  var dataSource:                SparkLineDataSource? {get set}
  var showCurrentValue:          Bool        {get set}
  var currentValueColor:         UIColor     {get set}
  var showRangeOverlay:          Bool        {get set}
  var rangeOverlayColor:         UIColor     {get set}
  
  var rangeOverlayLowerLimit:    NSNumber? {get set}
  var rangeOverlayUpperLimit:    NSNumber? {get set}
  
  init(data: [NSNumber], label: String)
  
  func disableOverlayIfLimitsInconsistent( _ showOverlay: Bool, upperLimit: NSNumber?, lowerLimit: NSNumber? ) -> Bool
  func configureOverlay( _ plotSpace: inout PlotSpace, upperLimit: NSNumber?, lowerLimit: NSNumber? )
  func drawOverlayIfEnabled( _ plotSpace: inout PlotSpace, renderer: Renderer)
  func drawValueMarker(_ values: [NSNumber], plotSpace: inout PlotSpace, xInc: CGFloat, yInc: Float, renderer: Renderer)
}

extension LineSparkLinePlotter {
  
  var MARKER_MIN_SIZE:       CGFloat    {return 4.0}     // maximum size of the anchor marker (in points)
  var DEF_MARKER_SIZE_FRAC:  CGFloat    {return 0.2}     // default fraction of the view height for the marker
  var MARKER_MAX_SIZE:       CGFloat    {return 8.0}     // maximum size of the anchor marker (in points)
  var CONSTANT_GRAPH_BUFFER: Float      {return 0.1}     // fraction to move the graph limits when min = max
  
  mutating func initialize(_ data: [NSNumber], label: String) {
    dataValues = data
    labelText = label
    computeRanges(dataValues!)
  }
  
  mutating func computeRanges(_ dataValues: [NSNumber]) {
    let computedValues = computeMaxMin( dataValues )
    dataMaximum = computedValues.max
    dataMinimum = computedValues.min
    rangeOverlayUpperLimit = dataMaximum
    rangeOverlayLowerLimit = dataMinimum
  }
  
  mutating func drawSparkLine(_ plotSpace: inout PlotSpace, dataValues: [NSNumber], renderer: Renderer ) {
    
    // Overlay goes "under" so must go first
    
    showRangeOverlay = disableOverlayIfLimitsInconsistent( showRangeOverlay, upperLimit: rangeOverlayUpperLimit , lowerLimit: rangeOverlayLowerLimit )
    
    configureOverlay( &plotSpace, upperLimit: rangeOverlayUpperLimit , lowerLimit: rangeOverlayLowerLimit )
    
    drawOverlayIfEnabled( &plotSpace, renderer: renderer )
    
    // Setup the drawing space
    
    // X scale is set to show all values
    
    let xinc = xInc( dataValues, penWidth: penWidth, plotSpace: plotSpace)
    
    // Y scale is auto-zoomed to specified limits (allowing for pen width)
    
    let yinc = yInc(penWidth, plotSpace: plotSpace)
    
    selectPenWidth(penWidth, scaleFactor: 2.0, renderer: renderer)
    
    selectPenColor(penColor, renderer: renderer)
    
    // Draw the values
    
    drawValues( dataValues, plotSpace: &plotSpace, xInc: xinc, yInc: yinc, renderer: renderer)
    
    // And the marker, if requested
    
    if showCurrentValue {
      drawValueMarker( dataValues, plotSpace: &plotSpace, xInc: xinc, yInc: yinc, renderer: renderer )
    }
  }
  
  func createSparkLabel(_ labelText: String, value: Float, bounds: CGRect, values: [NSNumber]) -> SparkLineLabel {
    let sparkLabel = SparkLineLabel(bounds: bounds,
                                    count: values.count,
                                    text: labelText,
                                    font: labelFont,
                                    value: NSNumber( value: value ),
                                    showValue: showCurrentValue,
                                    valueColor: currentValueColor,
                                    valueFormat: currentValueFormat,
                                    reverse: false)
    return sparkLabel
  }
  
  func drawLabelAndValue( _ sparkLabel: SparkLineLabel, renderer: Renderer ) {
    // first we draw the label using the specified font
    var textStart  = CGPoint(x: sparkLabel.textStartX, y: sparkLabel.textStartY)
    
    labelText!.draw(at: textStart, withAttributes:sparkLabel.attributes)
    
    // conditionally draw the current value in the chosen colour
    if showCurrentValue {
      renderer.saveState()
      renderer.setFill(currentValueColor)
      textStart = CGPoint(x: sparkLabel.textStartX + sparkLabel.labelDrawnSize.width, y: sparkLabel.textStartY)
      
      sparkLabel.formattedLabelValue.draw(at: textStart, withAttributes:sparkLabel.attributes)
      
      renderer.restoreState()
    }
  }
  
  func valueForLabel() -> Float {
    return dataValues!.last!.floatValue
  }
  
  func disableOverlayIfLimitsInconsistent( _ showOverlay: Bool, upperLimit: NSNumber?, lowerLimit: NSNumber? ) -> Bool {
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
  
  func configureOverlay( _ plotSpace: inout PlotSpace, upperLimit: NSNumber?, lowerLimit: NSNumber? ) {
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
  
  func drawOverlayIfEnabled( _ plotSpace: inout PlotSpace, renderer: Renderer) {
    
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
      
      renderer.setFill(rangeOverlayColor)
      let overlayRect = CGRect(x: GRAPH_X_BORDER, y: CGFloat(overlayOrigin), width: plotSpace.sparkWidth, height: overlayHeight)
      renderer.fillRect(overlayRect)
    }
  }
  
  func xInc(_ values: [NSNumber], penWidth: CGFloat, plotSpace: PlotSpace) -> CGFloat {
    // X scale is set to show all values
    
    return plotSpace.sparkWidth / CGFloat(values.count - 1)
  }
  
  func drawValueMarker(_ values: [NSNumber], plotSpace: inout PlotSpace, xInc: CGFloat, yInc: Float, renderer: Renderer) {
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
    
    let markRect = CGRect(x: markX - (markSize/2.0), y: markY - (markSize/2.0), width: markSize, height: markSize)
    renderer.setFill(currentValueColor)
    renderer.fillEllipse(markRect)
  }
  
  func validateYPos(_ value: AnyObject, yInc: Float, index: Int, plotSpace: PlotSpace) -> CGFloat {
    // Hook method
    var ypos: CGFloat = 0.0
    
    // warning and zero value for any non-NSNumber objects
    if value.isKind(of: NSNumber.self) {
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
  func yPlotValue(_ maxHeight: Float, yInc: Float, val: Float, offset: Float, penWidth: Float) -> CGFloat {
    let y = yInc * (val - offset)
    let pen = penWidth / 2.0
    let height = y + Float(GRAPH_Y_BORDER) + pen
    let ypv = maxHeight - height
    
    return CGFloat(ypv)
  }
  
}

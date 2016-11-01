//
//  WhiskerSparkLinePlotter.swift
//  sparklines
//
//  Created by Jim Holt on 9/2/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol WhiskerSparkLinePlotter: SparkLinePlotter {
  var dataSource:              WhiskerSparkLineDataSource? {get set}
  var showLabel:               Bool     {get set}
  var showHighlightOverlay:    Bool     {get set}
  var labelColor:              UIColor  {get set}
  var highlightOverlayColor:   UIColor  {get set}
  var xIncrement:              CGFloat  {get set}
  var whiskerColor:            UIColor  {get set}
  var highlightedWhiskerColor: UIColor  {get set}
  var tickWidth:               CGFloat  {get set}
  var tickColor:               UIColor  {get set}
  var longestRun:              Int?     {get set}
  var centerSparkLine:         Bool     {get set}
  
  init(data: [NSNumber], label: String, xIncrement: CGFloat, whiskerWidth: CGFloat)
  
  func pointCount( _ dataValues: [NSNumber] ) -> Int
  func xOffsetToCenterWhiskers(_ dataValues: [NSNumber], viewWidth: CGFloat, xInc: CGFloat ) -> CGFloat
  func selectTickPenWidth( _ tickWidth: CGFloat, scaleFactor: CGFloat, renderer: Renderer )
  func selectTimePenWidth( _ timeWidth: CGFloat, scaleFactor: CGFloat, renderer: Renderer )
  func drawWhiskerAtXpos( _ xpos: CGFloat, ypos: CGFloat, centerY: CGFloat, renderer: Renderer)
  func drawTickAtXpos( _ xpos: CGFloat,  xinc: CGFloat, tickColor: UIColor, plotSpace: PlotSpace, renderer: Renderer)
  func drawAxisToXpos( _ xpos:CGFloat, xOffset: CGFloat, ypos:CGFloat, centerY: CGFloat, renderer: Renderer )
}

extension WhiskerSparkLinePlotter {
  
  mutating func initialize(_ data: [NSNumber], label: String) {
    dataValues = data
    labelText = label
    computeRanges(dataValues!)
  }
  
  mutating func computeRanges(_ dataValues: [NSNumber]) {
    var values: [NSNumber]
    if let ds = dataSource {
      values = ds.dataValues as [NSNumber]
    } else {
      values = dataValues
    }
    let computedValues = computeMaxMin( values )
    dataMaximum = computedValues.max
    dataMinimum = computedValues.min
  }
  
  func drawSparkLine(_ plotSpace: inout PlotSpace, dataValues: [NSNumber], renderer: Renderer ) {
    
    // For whiskers, X scale is set to a fixed value
    // dataValues may be empty if we are using SparkLineDataSource
    
    let xinc = xInc( dataValues, penWidth: penWidth, plotSpace: plotSpace)
    
    plotSpace.xInc = xinc
    plotSpace.numberOfPoints = pointCount( dataValues )
    
    // Y scale is auto-zoomed to specified limits (allowing for pen width)
    
    let yinc = yInc(penWidth, plotSpace: plotSpace)
    
    selectPenWidth(penWidth, scaleFactor: 2.0, renderer: renderer)
    
    selectPenColor(penColor, renderer: renderer)
    
    // Needed for drawValues
    if centerSparkLine {
      plotSpace.xOffsetToCenter = xOffsetToCenterWhiskers( dataValues, viewWidth: plotSpace.fullWidth, xInc: xinc )
    }
    
    // overlay needs to go under...

    drawOverlayIfEnabled( &plotSpace, renderer: renderer )

    drawValues( dataValues, plotSpace: &plotSpace, xInc: xinc, yInc: yinc, renderer: renderer)

  }
  
  func pointCount( _ dataValues: [NSNumber] ) -> Int {
    var numberOfPoints: Int
    if let ds = dataSource {
      numberOfPoints = ds.numberOfDataPoints(self)
      
    } else {
      numberOfPoints = dataValues.count
    }
    return numberOfPoints
  }
  
  func xOffsetToCenterWhiskers(_ dataValues: [NSNumber], viewWidth: CGFloat, xInc: CGFloat ) -> CGFloat {
    var xOffsetToCenter: CGFloat?
    
    let numberOfPoints = pointCount(dataValues)
    
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
  
  func createSparkLabel(_ labelText: String, value: Float, bounds: CGRect, values: [NSNumber]) -> SparkLineLabel {
    let sparkLabel = SparkLineLabel(bounds: bounds,
                                    count: values.count,
                                    text: labelText,
                                    font: labelFont,
                                    value: NSNumber( value: value ),
                                    showValue: showLabel,
                                    valueColor: labelColor,
                                    valueFormat: currentValueFormat,
                                    reverse: true)
    return sparkLabel
  }
  
  func drawLabelAndValue( _ sparkLabel: SparkLineLabel, renderer: Renderer ) {
    if showLabel {
      
      var attrs = sparkLabel.attributes
      attrs![NSForegroundColorAttributeName] = labelColor
      
      var textStart  = CGPoint(x: sparkLabel.whiskerTextStartX!, y: sparkLabel.textStartY)
      
      sparkLabel.formattedLabelValue.draw(at: textStart, withAttributes:attrs)
      
      textStart = CGPoint(x: sparkLabel.whiskerTextStartX! + sparkLabel.valueDrawnSize.width, y: sparkLabel.textStartY)
      
      (" " + labelText!).draw(at: textStart, withAttributes:attrs)
    }
  }
  
  func valueForLabel() -> Float {
    return Float(longestRun!)
  }
  
  func selectTickPenWidth( _ tickWidth: CGFloat, scaleFactor: CGFloat, renderer: Renderer ) {
    // Ensure the tick pen is a suitable width for the device we are on (i.e. we use *pixels* and not points)
    if (tickWidth != 0.0) {
      renderer.setLineWidth( tickWidth / scaleFactor )
    } else {
      renderer.setLineWidth( TICK_PEN_WIDTH / scaleFactor )
    }
  }
  
  func selectTimePenWidth( _ timeWidth: CGFloat, scaleFactor: CGFloat, renderer: Renderer) {
    // Ensure the tick pen is a suitable width for the device we are on (i.e. we use *pixels* and not points)
    if (timeWidth != 0.0) {
      renderer.setLineWidth( timeWidth / scaleFactor )
    } else {
      renderer.setLineWidth( TIME_PEN_WIDTH / scaleFactor )
    }
  }
  
  func xInc( _: [NSNumber], penWidth: CGFloat, plotSpace _: PlotSpace) -> CGFloat {
    // X scale is set to fixed value from whisker view
    let xi = xIncrement
    return xi
  }
  
  // MARK: Drawing Methods
  
  func drawValues( _ values: [NSNumber], plotSpace: inout PlotSpace, xInc: CGFloat, yInc: Float, renderer: Renderer ) {
    // Retrieves the data and draws the binary outcome sparkline--whiskers, axis and tick marks.
    // Height and width for the sparkline are derived from the view bounds less borders.
    
    // Ghost White 248-248-255
    // White Smoke 245-245-245
    
    var lastXPos: CGFloat = 0.0;
    let centerY  = plotSpace.fullHeight/2.0
    
    renderer.beginPath()
    
    var numberOfPoints: Int = 0
    
    if let ds = dataSource {
      numberOfPoints = ds.numberOfDataPoints(self)
      
    } else {
      numberOfPoints = values.count
    }
    
    var xpos:          CGFloat
    var ypos:          CGFloat = 1.0
    var value:         NSNumber?
    var currentColor:  UIColor?
    
    for index in 0..<numberOfPoints {
      
      // Get the value and whisker color
      
      if let ds = dataSource {
        value        = ds.dataPointForIndex(self, index: index)
        currentColor = ds.whiskerColorForIndex(self, index: index)
        
      } else {
        value        = values[index]
        currentColor = whiskerColor
      }
      
      // And set the stroke color
      
      renderer.setStroke(currentColor!)
      
      // Calculate the x & y positions
      
      xpos = (xInc * CGFloat(index)) + GRAPH_X_BORDER + plotSpace.xOffsetToCenter
      ypos = validateYPos(value!, yInc:yInc, index:index, plotSpace: plotSpace)
      
      // Draw the whisker
      
      drawWhiskerAtXpos(xpos, ypos:ypos, centerY:centerY, renderer: renderer)
      
      // And a tick mark if needed
      
      if let ds = dataSource {
        if ds.tickForIndex( self, index: index ) {
          drawTickAtXpos( xpos,  xinc: xInc, tickColor: tickColor, plotSpace: plotSpace, renderer: renderer)
        }
      }
      
      lastXPos = xpos
    }
    
    // Draw the last tick
    
    xpos = (xInc * CGFloat(numberOfPoints)) + GRAPH_X_BORDER + plotSpace.xOffsetToCenter
    drawTickAtXpos(xpos, xinc:xInc, tickColor:tickColor, plotSpace: plotSpace, renderer: renderer)
    
    // And add the x axis
    
    drawAxisToXpos(lastXPos, xOffset: plotSpace.xOffsetToCenter, ypos: ypos, centerY:centerY, renderer: renderer)
  }
  
  func drawWhiskerAtXpos( _ xpos: CGFloat, ypos: CGFloat, centerY: CGFloat, renderer: Renderer) {
    //   Draw a whisker from (xpos,centerY) to (xpos, ypos) in context.
    
    selectPenWidth(penWidth, scaleFactor: 2.0, renderer: renderer)
    renderer.moveTo( CGPoint(x: xpos, y: centerY))
    renderer.lineTo( CGPoint(x: xpos, y: ypos))
    renderer.closePath()
    renderer.strokePath()
  }
  
  func drawTickAtXpos( _ xpos: CGFloat,  xinc: CGFloat, tickColor: UIColor, plotSpace: PlotSpace, renderer: Renderer) {
    // Draw a tick of color tickColor from (xpos-xinc, 0.0) to (xpos-xinc, self.fullHeight) in context.
    let xposGrid = xpos - 0.5 * xinc
    renderer.setStroke(tickColor)
    selectTickPenWidth(tickWidth, scaleFactor: 2.0, renderer: renderer)
    
    renderer.moveTo( CGPoint(x: xposGrid, y: 0.0))
    renderer.lineTo( CGPoint(x: xposGrid, y: plotSpace.fullHeight))
    renderer.closePath()
    
    // draw the tick
    renderer.strokePath()
  }
  
  func drawAxisToXpos( _ xpos:CGFloat, xOffset: CGFloat, ypos:CGFloat, centerY: CGFloat, renderer: Renderer ) {
    
    selectPenWidth(penWidth, scaleFactor: 2.0, renderer: renderer)
    selectPenColor(penColor, renderer: renderer)
    
    renderer.moveTo( CGPoint(x: 0.0 + GRAPH_Y_BORDER + xOffset, y: centerY))
    renderer.lineTo( CGPoint(x: xpos+0.5 , y: centerY))
    renderer.closePath()
    
    // draw the graph line (path)
    renderer.strokePath()
  }
  
  func validateYPos(_ value: AnyObject, yInc: Float, index: Int, plotSpace: PlotSpace) -> CGFloat {
    var ypos: CGFloat = 0.0
    
    if value.isKind(of: NSNumber.self) {
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
  
  func drawOverlayIfEnabled( _ plotSpace: inout PlotSpace, renderer: Renderer) {
    
    if let ds = dataSource {
      // show the graph overlay if (still) enabled
      if showHighlightOverlay {
        
        var originY: CGFloat
        let sizeY = plotSpace.maxWhiskerHeight - GRAPH_Y_BORDER
        
        if ds.streakType.rawValue == 1 {
          originY = plotSpace.fullHeight/2.0 - sizeY
        } else {
          originY = plotSpace.fullHeight/2.0
        }
        
        for (_, run) in ds.streaks.enumerated() {
          
          let originX = GRAPH_X_BORDER + (CGFloat(run.0) * plotSpace.xInc!) + 0.5
          let sizeX   = CGFloat(run.1-1) * plotSpace.xInc!
          
          renderer.setFill(highlightOverlayColor)
          let overlayRect = CGRect(x: originX, y: originY, width: sizeX, height: sizeY)
          renderer.fillRect( overlayRect )
        }
      }

    } else {
      print("Warning: whisker overlays must be enabled with a data source")
    }
  }
  
  @inline(__always)
  func yPlotValue(_ maxHeight: Float, yInc: Float, val: Float, offset: Float, penWidth: Float) -> CGFloat {
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

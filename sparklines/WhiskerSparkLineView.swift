//
//  WhiskerSparkLineView.swift
//  sparklines
//
//  Created by Jim Holt on 8/25/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

public class WhiskerSparkLineView: UIView, WhiskerSparkLinePlotter {
  
  // MARK: Stored Properties
  
  // Array of NSNumber values to display
  var dataValues: [NSNumber]?
    {
    didSet {
      computeRanges(dataValues!)
      
      self.setNeedsDisplay()
    }
  }
  
  // Text to be displayed beside the graph data
  var labelText: String?
    {
    didSet {
      self.setNeedsDisplay()
    }
  }

  var labelFont: String = LABEL_FONT
  
  // Color of the label text (default: dark gray)
  // Color of the label text (default: dark gray)
  var labelColor: UIColor = DEFAULT_LABEL_COL
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  // Enable centering of the sparkline in the view
  var centerSparkLine: Bool = true
    {
    didSet {
      self.setNeedsDisplay()
    }
  }

  // Enable display of the numerical current (last) value (default: YES).
  var showLabel: Bool = true
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  // The format (in printf() style) of the numeric current value.
  var currentValueFormat: String = "%.1f"
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  // Flag to enable the display of the range overlay (default: NO).
  var showHighlightOverlay: Bool = false
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  // The UIColor used for the range overlay.
  var highlightOverlayColor: UIColor = DEFAULT_HIGHLIGHT_OVERLAY_COL
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  // The UIColor used for the sparkline colour itself
  var penColor: UIColor = PEN_COL
  
  //! The float value used for the sparkline pen width
  var penWidth: CGFloat = DEFAULT_GRAPH_PEN_WIDTH
  
  var dataMinimum: NSNumber?
  var dataMaximum: NSNumber?
  
  var dataSource: WhiskerSparkLineDataSource? {
    didSet {
      longestRun = dataSource!.longestRun
    }
  }
  
  // For the whisker view, xIncrement is set, not calculated.
  var xIncrement:              CGFloat = 2.0
  var whiskerColor:            UIColor = UIColor.blackColor()
  var highlightedWhiskerColor: UIColor = UIColor(red:0.99, green:0.14, blue:0.22, alpha:1.0) // scarlet
  
  var tickWidth:               CGFloat = DEFAULT_TICK_PEN_WIDTH
  var tickColor:               UIColor = UIColor.blackColor()
  var longestRun:              Int? = 0

  // MARK: NSObject Lifecycle
  
  required public init(data: [NSNumber], frame: CGRect, label: String) {
    super.init(frame: frame)
    initialize( data, label: label)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    let data: [NSNumber] = []
    initialize( data, label: "")
  }
  
  // MARK: Drawing Methods
  
  // draws all the elements of this view
  public override func drawRect(rect: CGRect) {
    
    let context = UIGraphicsGetCurrentContext()
    
    drawSparkline(labelText!,
                  bounds: self.bounds,
                  dataMinimum: -1,
                  dataMaximum: 1,
                  dataValues:  dataValues!,
                  renderer: context! )
  }
  
  func drawValues( values: [NSNumber], inout plotSpace: PlotSpace, xInc: CGFloat, yInc: Float, renderer: Renderer ) {
    // Retrieves the data and draws the binary outcome sparkline--whiskers, axis and tick marks.
    // Height and width for the sparkline are derived from the view bounds less borders.
  
    // Ghost White 248-248-255
    // White Smoke 245-245-245
    let tickColor = UIColor(red:245/255, green:245/255, blue:245/255, alpha:0.1)
  
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
    
      currentColor!.setStroke()
    
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
  
}

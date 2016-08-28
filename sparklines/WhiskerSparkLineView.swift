//
//  WhiskerSparkLineView.swift
//  sparklines
//
//  Created by Jim Holt on 8/25/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

let TIME_PEN_WIDTH: CGFloat = 1.0
let DEFAULT_TICK_PEN_WIDTH: CGFloat  = 4.0

var TICK_PEN_WIDTH                   = DEFAULT_TICK_PEN_WIDTH    // pen width for the graph line (in *pixels*)

public class WhiskerSparkLineView: SparkLineView {
  
  // For the whisker view, xIncrement is set, not calculated.
  var xIncrement:              CGFloat = 1.0
  var whiskerColor:            UIColor = UIColor.blackColor()
  var highlightedWhiskerColor: UIColor = UIColor.redColor()
  var viewCenterX:             CGFloat = 0.0
  
  var tickWidth: CGFloat? = DEFAULT_TICK_PEN_WIDTH
  var timeWidth: CGFloat? = TIME_PEN_WIDTH
  
  // MARK: NSObject lifecycle
  
  override func initialize(data: [NSNumber], label: String) {
    super.initialize(data, label: "")
    viewCenterX = 8.0
  }
  
  override func drawLabelIfNeeded( labelText: String?, dataValues: [NSNumber], context: CGContextRef) -> CGSize {
    // Null out superclass method as Whisker view has no label.
    
    return CGSizeMake(0.0, 0.0)
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
  
  override func xInc(values: [NSNumber], penWidth: CGFloat, plotSpace: PlotSpace) -> CGFloat {
    // X scale is set to show all values
    let xi = penWidth
    print("whisker view: penWidth \(penWidth), xInc \(xi)")
    return xi
  }
  
  override func drawValues( values: [NSNumber], inout plotSpace: PlotSpace, xInc: CGFloat, yInc: Float, context: CGContextRef ) {
    // Retrieves the data and draws the binary outcome sparkline--whiskers, axis and tick marks.
    // Height and width for the sparkline are derived from the view bounds less borders.
  
    // Ghost White 248-248-255
    // White Smoke 245-245-245
    let tickColor = UIColor(red:245/255, green:245/255, blue:245/255, alpha:0.1)
  
    var lastXPos: CGFloat = 0.0;
    let centerY  = plotSpace.fullHeight/2.0
  
    CGContextBeginPath(context)
  
    let numberOfPoints = values.count
  
    let viewWidth = self.bounds.size.width
    let graphWidth = xInc * CGFloat(numberOfPoints)
    viewCenterX = (viewWidth - graphWidth)/2.0
    
    print("whisker view setting view padding \(viewCenterX) for view X \(viewWidth), graph X \(graphWidth)")
  
    var xpos: CGFloat
    var ypos: CGFloat = 1.0
    
    for (index, value) in values.enumerate() {
    
      // And the whisker color
    
      whiskerColor.setStroke()
    
      // Calculate the x & y positions
    
      xpos = (xInc * CGFloat(index)) + GRAPH_X_BORDER + viewCenterX
      ypos = validateYPos(value, yInc:yInc, index:index, plotSpace: plotSpace)
    
      // Draw the whisker
    
      drawWhiskerAtXpos(xpos, ypos:ypos, centerY:centerY, context:context)
    
    // And a tick mark if needed
    
  //    if ([self.dataSource respondsToSelector:@selector(sparklineView:tickForIndex:)] &&
  //    [self.dataSource sparklineView:self tickForIndex:index]) {
      
  //    [self drawTickAtXpos:xpos xinc:xinc tickColor:tickColor context:context];
  //    }
      
  //    if ([self.dataSource respondsToSelector:@selector(sparklineView:timeForIndex:)] &&
  //    [self.dataSource sparklineView:self timeForIndex:index]) {
    
  //    [self drawTickAtXpos:xpos xinc:xinc tickColor:[UIColor redColor] context:context];
  //    }
      lastXPos = xpos
    }
    
    // Draw the last tick
    
    xpos = (xInc * CGFloat(numberOfPoints)) + GRAPH_X_BORDER + viewCenterX
    drawTickAtXpos(xpos, xinc:xInc, tickColor:tickColor, plotSpace: plotSpace, context:context)
    
    // And add the x axis
    
    drawAxisToXpos(lastXPos, ypos: ypos, centerY:centerY, context:context)
  }
  
  // MARK: Drawing convenience methods
  
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
    selectTickPenWidth(tickWidth!, context: context)
    
    CGContextMoveToPoint(context, xposGrid, 0.0);
    CGContextAddLineToPoint(context, xposGrid, plotSpace.fullHeight);
    CGContextClosePath(context);
    
    // draw the tick
    CGContextStrokePath(context);
  }
  
  func drawAxisToXpos( xpos:CGFloat, ypos:CGFloat, centerY: CGFloat, context: CGContextRef ) {
    selectPenColor(penColor)
    
    CGContextMoveToPoint(context, 0.0 + GRAPH_Y_BORDER + viewCenterX, centerY);
    CGContextAddLineToPoint(context, xpos+0.5 , centerY);
    CGContextClosePath(context);
    
    // draw the graph line (path)
    CGContextStrokePath(context);
  }
  
  override func drawValueMarker(values: [NSNumber], inout plotSpace: PlotSpace, xInc: CGFloat, yInc: Float, context: CGContextRef) {
    // Null out superclass method as Whisker view has no label.
  }

  // returns the Y plot value, given the limitations we have
  @inline(__always)
  override func yPlotValue(maxHeight: Float, yInc: Float, val: Float, offset: Float, penWidth: Float) -> CGFloat {
    // returns the Y plot value, given the limitations we have
    var result: Float
    
    let yBorder = GRAPH_Y_BORDER
    
    result = maxHeight / 2.0
    
    if val == 1.0 {
      result = maxHeight - Float(yBorder)
    } else if (val == -1.0) {
      result = 0.0 + Float(yBorder)
    }
    result = maxHeight - result    // flip
    
    return CGFloat(result)
  }
}

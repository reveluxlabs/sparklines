//
//  SparkLineView.swift
//  sparklines
//
//  Created by Jim Holt on 8/23/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

// MARK: Class Constants

let LABEL_FONT                        = "Helvetica"
let MAX_TEXT_FRAC: CGFloat            = 0.5     // maximum fraction of view to give to the textual part
let DEFAULT_FONT_SIZE: CGFloat        = 12.0    // we'll try to use this font size
let MIN_FONT_SIZE: CGFloat            = 10.0    // this is the minimum font size, after that, we'll truncate

let MARKER_MIN_SIZE: CGFloat          = 4.0     // maximum size of the anchor marker we'll use (in points)
let DEF_MARKER_SIZE_FRAC: CGFloat     = 0.2     // default fraction of the view height we'll use for the anchor marker
let MARKER_MAX_SIZE: CGFloat          = 8.0     // maximum size of the anchor marker we'll use (in points)

let GRAPH_X_BORDER: CGFloat           = 2.0     // horizontal border width for the graph line (in points)
let GRAPH_Y_BORDER: CGFloat           = 2.0     // vertical border width for the graph line (in points)

let CONSTANT_GRAPH_BUFFER: Float      = 0.1     // fraction to move the graph limits when min = max

let DEFAULT_LABEL_COL                 = UIColor.darkGrayColor()      // default label text colour
let DEFAULT_CURRENTVALUE_COL          = UIColor.blueColor()          // default current value colour (including the anchor marker)
let DEFAULT_OVERLAY_COL               = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1.0)   // default overlay colour (light gray)
let PEN_COL                           = UIColor.blackColor()         // default graph line colour (black)
let DEFAULT_GRAPH_PEN_WIDTH: CGFloat  = 1.0

var GRAPH_PEN_WIDTH                   = DEFAULT_GRAPH_PEN_WIDTH    // pen width for the graph line (in *pixels*)

// no user-tweakable bits beyond this point...


// returns the Y plot value, given the limitations we have
@inline(__always)
func yPlotValue(maxHeight: Float, yInc: Float, val: Float, offset: Float, penWidth: Float) -> CGFloat {
  let y = yInc * (val - offset)
  let pen = penWidth / 2.0
  let height = y + Float(GRAPH_Y_BORDER) + pen
  let ypv = maxHeight - height
  
  return CGFloat(ypv)
}

public class SparkLineView: UIView {
  
  // MARK: Stored Properties
  
  // Array of NSNumber values to display
  var dataValues: [NSNumber]?
    {
    didSet {
      createDataStatistics()
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
  // Color of the label text (default: dark gray)
  var labelColor: UIColor = DEFAULT_LABEL_COL
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  // Flag to enable display of the numerical current (last) value (default: YES).
  var showCurrentValue: Bool = true
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  // The UIColor used to display the numeric current value and the marker anchor.
  var currentValueColor: UIColor = DEFAULT_CURRENTVALUE_COL
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
  var showRangeOverlay: Bool = false
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  // The UIColor used for the range overlay.
  var rangeOverlayColor: UIColor = DEFAULT_OVERLAY_COL
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  // The UIColor used for the sparkline colour itself
  var penColor: UIColor = PEN_COL
  
  //! The float value used for the sparkline pen width
  var penWidth: CGFloat = DEFAULT_GRAPH_PEN_WIDTH
  
  var rangeOverlayLowerLimit: NSNumber?
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  var rangeOverlayUpperLimit: NSNumber?
    {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  var dataMinimum: NSNumber?
  var dataMaximum: NSNumber?
  
  // MARK: NSObject Lifecycle
  
  // designated initializer
  init(data: [NSNumber], frame: CGRect, label: String) {
    super.init(frame: frame)
    initialize( data, label: label)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize( [], label: "")
 }
  
  convenience init( data: [NSNumber], frame: CGRect ) {
    self.init( data: data, frame:frame, label: "")
  }
  
  convenience override init( frame: CGRect ) {
    self.init( data: [], frame:frame, label: "")
  }
  
  public override func awakeFromNib() {
    setup()
  }
  
  // MARK: Convenience 
  
  func initialize(data: [NSNumber], label: String) {
    dataValues = data
    labelText = label
    createDataStatistics()
    setup()
    self.setNeedsDisplay()
  }
  
  // configures the defaults (used in init or when waking from a nib)
  func setup() {
    
    if let dMin = dataMinimum {
      rangeOverlayLowerLimit = dMin
      rangeOverlayUpperLimit = dataMaximum!
    }
    
    // ensure we redraw correctly when resized
    self.contentMode = UIViewContentMode.Redraw
    
    // and we have a nice rounded shape...
    self.layer.masksToBounds = true
    self.layer.cornerRadius = 5.0
  }
  
  // Loads the data values, and calculates the min and max values (for auto-scaling)
  func createDataStatistics() {
  
    let numData = self.dataValues!.count
    
    /// special cases first
    if numData == 0 {
      dataMinimum = nil
      dataMaximum = nil
    
    } else if numData == 1 {
      dataMinimum = dataValues!.last
      dataMaximum = dataValues!.last
    
    } else {
      var min = dataValues![0].floatValue
      var max = min
      
      // extract the min and max values (ignore any non-NSNumber objects)
      for (_, value) in self.dataValues!.enumerate() {
        if value.isKindOfClass(NSNumber) {
          let val = value.floatValue
          if val < min {
              min = val
          } else if val > max {
              max = val
          }
        }
      
        dataMinimum = min
        dataMaximum = max
      }
    }
  }

  // MARK: Drawing Methods
  
  // draws all the elements of this view
  public override func drawRect(rect: CGRect) {
  
    let context = UIGraphicsGetCurrentContext()
  
    // ---------------------------------------------------
    // Text label Drawing
    // ---------------------------------------------------
    
    let maxTextWidth = CGRectGetWidth(self.bounds) * MAX_TEXT_FRAC
    print("max text width \(maxTextWidth) =  \(NSStringFromCGSize(self.bounds.size)) * \(MAX_TEXT_FRAC)")
    
    // see how much text we have to show
  
    var graphText = labelText == nil ? "not set" : String(UTF8String: labelText!)!
    
    let formattedValue = " ".stringByAppendingFormat(currentValueFormat, dataValues!.last!.floatValue)

    if showCurrentValue {
      graphText = graphText + formattedValue
    }
    print("graph text \(graphText)")
  
    // calculate the width the text would take with the specified font
    var font = UIFont(name:LABEL_FONT, size:DEFAULT_FONT_SIZE)

    let textSize = frameForText(graphText,
                                sizeWithFont:font!,
                                constrainedToSize:CGSizeMake(maxTextWidth, DEFAULT_FONT_SIZE+4),
                                lineBreakMode:NSLineBreakMode.ByClipping)

    print("text size with default font \( NSStringFromCGSize(textSize))")
    
    let actualFontSize: CGFloat =
      textSize.width <= (MAX_TEXT_FRAC * self.bounds.size.width) ? DEFAULT_FONT_SIZE : MIN_FONT_SIZE
  
    // first we draw the label
    let textStartX = (CGRectGetWidth(self.bounds) * 0.975) - textSize.width
    let textStartY = CGRectGetMidY(self.bounds) - (textSize.height / 2.0)
    var textStart  = CGPointMake(textStartX, textStartY)
    
    print("actual font size \(actualFontSize), textStartX \(textStartX), textStartY \(textStartY)")
    
    // using the specified font
    font = UIFont(name:LABEL_FONT, size:actualFontSize)
    
    let attrs = [ NSFontAttributeName : font! ]
    
    let labelDrawnSize = frameForText(labelText!,
                            sizeWithFont:font!,
                            constrainedToSize:CGSizeMake(maxTextWidth, actualFontSize+4),
                            lineBreakMode:NSLineBreakMode.ByClipping)

    print("label drawn size \(NSStringFromCGSize(labelDrawnSize))")
    print("+----------------------------------")

    labelText!.drawAtPoint(textStart, withAttributes:attrs)
 
    // conditionally draw the current value in the chosen colour
    if showCurrentValue {
      CGContextSaveGState(context)
      currentValueColor.setFill()
      textStart = CGPointMake(textStartX + labelDrawnSize.width, textStartY)
      
      formattedValue.drawAtPoint(textStart, withAttributes:attrs)
        
      CGContextRestoreGState(context)
    }
  
    // ---------------------------------------------------
    // Graph Drawing
    // ---------------------------------------------------
    
    // calculate the view fraction that will be the graph
    let graphSize = (CGRectGetWidth(self.bounds) * 0.95) - textSize.width
    let graphFrac = graphSize / CGRectGetWidth(self.bounds)
    
    // calculate the graph area and X & Y widths and scales
    let dataMin = self.dataMinimum!.floatValue
    let dataMax = self.dataMaximum!.floatValue
    
    let fullWidth = CGRectGetWidth(self.bounds)
    let fullHeight = CGRectGetHeight(self.bounds)
    let sparkWidth  = (fullWidth  - (2 * GRAPH_X_BORDER)) * graphFrac
    let sparkHeight = fullHeight - (2 * GRAPH_Y_BORDER)
    
    // defaults: upper and lower graph bounds are data maximum and minimum, respectively
    var graphMax = dataMax
    var graphMin = dataMin
  
    // disable overlay if the upper limit is at or below the lower limit
    if showRangeOverlay &&
       rangeOverlayUpperLimit != nil &&
       rangeOverlayLowerLimit != nil &&
       rangeOverlayUpperLimit!.floatValue <= rangeOverlayLowerLimit!.floatValue {
      showRangeOverlay = false
    }

    // default: undefined overlay limit means "no limit", so overlay will extend to view border
    var overlayOrigin: CGFloat = 0.0
    var overlayHeight: CGFloat = fullHeight
  
    // upper scale limit will be the maximum of (defined) overlay and data maxima
    if (rangeOverlayUpperLimit != nil) {
      let rangeUpper = rangeOverlayUpperLimit!.floatValue
      if (rangeUpper > graphMax) {
        graphMax = rangeUpper
      }
    }
    
    // lower scale limit will be the minimum of (defined) overlay and data minima
    if (self.rangeOverlayLowerLimit != nil) {
      let rangeLower = rangeOverlayLowerLimit!.floatValue
      if (rangeLower < graphMin) {
        graphMin = rangeLower
      }
    }
  
    // special case if min = max, push the limits 10% further
    if (graphMin == graphMax) {
      graphMin *= 1.0 - CONSTANT_GRAPH_BUFFER
      graphMax *= 1.0 + CONSTANT_GRAPH_BUFFER
    }
  
    // show the graph overlay if (still) enabled
    if showRangeOverlay {
    
      // set the graph location of the overlay upper and lower limits, if defined
      if rangeOverlayUpperLimit != nil {
        overlayOrigin = yPlotValue(Float(fullHeight),
                                   yInc: Float(sparkHeight) / (graphMax - graphMin),
                                   val: rangeOverlayUpperLimit!.floatValue,
                                   offset:  graphMin,
                                   penWidth:  Float(penWidth))
      }
      if rangeOverlayLowerLimit != nil {
        let lowerY = yPlotValue(Float(fullHeight),
                                yInc: Float(sparkHeight) / (graphMax - graphMin),
                                val: rangeOverlayLowerLimit!.floatValue,
                                offset:  graphMin,
                                penWidth:  Float(penWidth))
        overlayHeight = CGFloat(lowerY) - overlayOrigin
      }
    
      // draw the overlay
      self.rangeOverlayColor.setFill()
      let overlayRect = CGRectMake(GRAPH_X_BORDER, CGFloat(overlayOrigin), sparkWidth, overlayHeight)
      CGContextFillRect(context, overlayRect)
    }
  
    // X scale is set to show all values
    let xinc = sparkWidth / CGFloat(self.dataValues!.count - 1)
    
    // Y scale is auto-zoomed to specified limits (allowing for pen width)
    let yInc = (Float(sparkHeight) - Float(penWidth)) / (graphMax - graphMin)
  
    // ensure the pen is a suitable width for the device we are on (i.e. we use *pixels* and not points)
    if penWidth != 0.0 {
      CGContextSetLineWidth(context, self.penWidth / self.contentScaleFactor)
    } else {
      CGContextSetLineWidth(context, GRAPH_PEN_WIDTH / self.contentScaleFactor)
    }
  
    // Customisation to allow pencolour changes
    if penColor != PEN_COL {
      penColor.setStroke()
    } else {
      PEN_COL.setStroke()
    }
  
    CGContextBeginPath(context)
  
    // iterate over the data items, plotting the graph path
    for (index, value) in self.dataValues!.enumerate() {
  
      let xpos: CGFloat = xinc * CGFloat(index) + GRAPH_X_BORDER
      var ypos: CGFloat = 0.0
  
      // warning and zero value for any non-NSNumber objects
      if value.isKindOfClass(NSNumber) {
        ypos = yPlotValue(Float(fullHeight),
                          yInc: yInc,
                          val: value.floatValue,
                          offset: graphMin,
                          penWidth: Float(penWidth))

      } else {
        NSLog("non-NSNumber object (%@) found in data (index %lu), zero value used", value, index)
        ypos = yPlotValue(Float(fullHeight),
                          yInc: yInc,
                          val: 0.0,
                          offset: graphMin,
                          penWidth: Float(penWidth))
      }
  
      if (index > 0) {
        CGContextAddLineToPoint(context, xpos, ypos)
      } else {
        CGContextMoveToPoint(context, xpos, ypos)
      }
    }
  
    // draw the graph line (path)
    CGContextStrokePath(context)
  
    // draw the value marker circle, if requested
    if showCurrentValue {
    
      let markX = xinc * CGFloat(self.dataValues!.count-1) + GRAPH_X_BORDER
      let markY = yPlotValue(Float(fullHeight),
                             yInc: yInc,
                             val: dataValues!.last!.floatValue,
                             offset: graphMin,
                             penWidth: Float(penWidth))
    
      // calculate the accent marker size, with limits
      var markSize = fullHeight * DEF_MARKER_SIZE_FRAC
      if (markSize < MARKER_MIN_SIZE) {
        markSize = MARKER_MIN_SIZE
      } else if markSize > MARKER_MAX_SIZE {
        markSize = MARKER_MAX_SIZE
      }
    
      let markRect = CGRectMake(markX - (markSize/2.0), markY - (markSize/2.0), markSize, markSize)
      self.currentValueColor.setFill()
      CGContextFillEllipseInRect(context, markRect)
    }
  }
  
  func frameForText( text: String, sizeWithFont font: UIFont, constrainedToSize maxSize: CGSize, lineBreakMode: NSLineBreakMode ) -> CGSize {
    var paragraphStyle: NSMutableParagraphStyle
    var attributes:     [String: AnyObject]
    var textRect:       CGRect
    
    paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.setParagraphStyle(NSParagraphStyle.defaultParagraphStyle())
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    attributes = [NSFontAttributeName           : font,
                  NSParagraphStyleAttributeName : paragraphStyle
    ]
    
    
    textRect = text.boundingRectWithSize(maxSize,
                                         options:NSStringDrawingOptions.UsesLineFragmentOrigin,
                                         attributes:attributes,
                                         context:nil)
    
    return textRect.size;
  }

}
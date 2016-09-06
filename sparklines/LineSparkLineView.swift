//
//  LineSparkLineView.swift
//  sparklines
//
//  Created by Jim Holt on 8/25/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

public class LineSparkLineView: UIView, LineSparkLinePlotter {
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
  
  var dataSource: SparkLineDataSource?

  
  // MARK: NSObject Lifecycle
  
  required public init(data: [NSNumber], frame: CGRect, label: String) {
    super.init(frame: frame)
    initialize( data, label: label)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize( [], label: "")
  }
  
  // MARK: Drawing Methods
  
  // draws all the elements of this view
  public override func drawRect(rect: CGRect) {
    
    let context = UIGraphicsGetCurrentContext()
    
    drawSparkline(labelText!,
                  bounds: self.bounds,
                  dataMinimum: dataMinimum!.floatValue,
                  dataMaximum: dataMaximum!.floatValue,
                  dataValues:  dataValues!,
                  renderer:    context!)
  }

}

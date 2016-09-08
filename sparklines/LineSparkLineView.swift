//
//  LineSparkLineView.swift
//  sparklines
//
//  Created by Jim Holt on 8/25/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

public class LineSparkLineView: UIView {

  // MARK: Stored Properties
  
//  // Array of NSNumber values to display
//  var dataValues: [NSNumber]?
//  
//  // Text to be displayed beside the graph data
//  var labelText: String?
//  
//  var labelFont: String = LABEL_FONT
//  
//  // Color of the label text (default: dark gray)
//  var labelColor: UIColor = DEFAULT_LABEL_COL
//  
//  // Flag to enable display of the numerical current (last) value (default: YES).
//  var showCurrentValue: Bool = true
//  // The UIColor used to display the numeric current value and the marker anchor.
//  var currentValueColor: UIColor = DEFAULT_CURRENTVALUE_COL
//  // The format (in printf() style) of the numeric current value.
//  var currentValueFormat: String = "%.1f"
//  
//  // Flag to enable the display of the range overlay (default: NO).
//  var showRangeOverlay: Bool = false
//  // The UIColor used for the range overlay.
//  var rangeOverlayColor: UIColor = DEFAULT_OVERLAY_COL
//  
//  // The UIColor used for the sparkline colour itself
//  var penColor: UIColor = PEN_COL
//  
//  //! The float value used for the sparkline pen width
//  var penWidth: CGFloat = DEFAULT_GRAPH_PEN_WIDTH
//  
//  var rangeOverlayLowerLimit: NSNumber?
//  var rangeOverlayUpperLimit: NSNumber?
//  
//  var dataMinimum: NSNumber?
//  var dataMaximum: NSNumber?
//  
//  var dataSource: SparkLineDataSource?
  
  var lineSpark: LineSparkLine?

  
  // MARK: NSObject Lifecycle
  
  required public init(data: [NSNumber], frame: CGRect, label: String) {
    super.init(frame: frame)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override public func awakeFromNib() {
    configureView()
  }
  
  // configures the defaults (used in init or when waking from a nib)
  func configureView() {
    
    // ensure we redraw correctly when resized
    self.contentMode = UIViewContentMode.Redraw
    
    // and we have a nice rounded shape...
    self.layer.masksToBounds = true
    self.layer.cornerRadius = 5.0
  }

  // MARK: Drawing Methods
  
  // draws all the elements of this view
  public override func drawRect(rect: CGRect) {
    
    let context = UIGraphicsGetCurrentContext()
    
    lineSpark!.drawSparkline(lineSpark!.labelText!,
                  bounds: self.bounds,
                  dataMinimum: lineSpark!.dataMinimum!.floatValue,
                  dataMaximum: lineSpark!.dataMaximum!.floatValue,
                  dataValues:  lineSpark!.dataValues!,
                  renderer:    context!)
  }

}

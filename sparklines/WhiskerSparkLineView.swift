//
//  WhiskerSparkLineView.swift
//  sparklines
//
//  Created by Jim Holt on 8/25/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

public class WhiskerSparkLineView: UIView {
  
//  // MARK: Stored Properties
//  
//  // Array of NSNumber values to display
//  var dataValues: [NSNumber]?
//  
//  // Text to be displayed beside the graph data
//  var labelText: String?
//
//  var labelFont: String = LABEL_FONT
//  
//  // Color of the label text (default: dark gray)
//  // Color of the label text (default: dark gray)
//  var labelColor: UIColor = DEFAULT_LABEL_COL
//  
//  // Enable centering of the sparkline in the view
//  var centerSparkLine: Bool = true
//
//  // Enable display of the numerical current (last) value (default: YES).
//  var showLabel: Bool = true
//  // The format (in printf() style) of the numeric current value.
//  var currentValueFormat: String = "%.1f"
//  
//  // Flag to enable the display of the range overlay (default: NO).
//  var showHighlightOverlay: Bool = false
//  // The UIColor used for the range overlay.
//  var highlightOverlayColor: UIColor = DEFAULT_HIGHLIGHT_OVERLAY_COL
//  
//  // The UIColor used for the sparkline colour itself
//  var penColor: UIColor = PEN_COL
//  
//  //! The float value used for the sparkline pen width
//  var penWidth: CGFloat = DEFAULT_GRAPH_PEN_WIDTH
//  
//  var dataMinimum: NSNumber?
//  var dataMaximum: NSNumber?
//  
//  var dataSource: WhiskerSparkLineDataSource? {
//    didSet {
//      longestRun = dataSource!.longestRun
//    }
//  }
//  
//  // For the whisker view, xIncrement is set, not calculated.
//  var xIncrement:              CGFloat = 2.0
//  var whiskerColor:            UIColor = UIColor.blackColor()
//  var highlightedWhiskerColor: UIColor = UIColor(red:0.99, green:0.14, blue:0.22, alpha:1.0) // scarlet
//  
//  var tickWidth:               CGFloat = DEFAULT_TICK_PEN_WIDTH
//  var tickColor:               UIColor = UIColor.blackColor()
//  var longestRun:              Int? = 0
  
  var whiskerSpark:  WhiskerSparkLine?

  // MARK: NSObject Lifecycle
  
  required public init(data: [NSNumber], frame: CGRect, label: String) {
    super.init(frame: frame)
//    initialize( data, label: label)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
//    let data: [NSNumber] = []
//    initialize( data, label: "")
  }
  
//  func initialize( data: [NSNumber], label: String ) {
//    dataValues = data
//    labelText = label
//    whiskerSpark = WhiskerSparkLine(data: dataValues!, label: labelText!)
//    configureView()
//  }
  
  override public func awakeFromNib() {
    configureView()
  }

  // Configures the defaults
  func configureView() {

    // ensure we redraw correctly when resized
    self.contentMode = UIViewContentMode.Redraw

    // and we have a nice rounded shape...
    self.layer.masksToBounds = true
    self.layer.cornerRadius = 5.0
  }

  // Hook the drawing method for the view
  public override func drawRect(rect: CGRect) {
    
    let context = UIGraphicsGetCurrentContext()
    
    whiskerSpark!.drawSparkline(whiskerSpark!.labelText!,
                  bounds: self.bounds,
                  dataMinimum: -1,
                  dataMaximum: 1,
                  dataValues:  whiskerSpark!.dataValues!,
                  renderer: context! )
  }

}

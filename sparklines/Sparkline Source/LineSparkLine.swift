//
//  LineSparkLine.swift
//  sparklines
//
//  Created by Jim Holt on 9/6/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

struct LineSparkLine: LineSparkLinePlotter {
  
  var dataValues:         [NSNumber]?                         // Values to display
  var labelText:          String?                             // Text to be displayed beside the graph data
  var labelFont:          String  = LABEL_FONT
  var labelColor:         UIColor = DEFAULT_LABEL_COL         // Color of the label text (default: dark gray)
  var showCurrentValue:   Bool    = true                      // Enable display of the numerical current (last) value
  var currentValueColor:  UIColor = DEFAULT_CURRENTVALUE_COL  // Used to display the numeric current value and the marker anchor
  var currentValueFormat: String  = "%.1f"                    // Format of the numeric current value
  var showRangeOverlay:   Bool    = false                     // Flag to enable the display of the range overlay (default: NO)
  var rangeOverlayColor:  UIColor = DEFAULT_OVERLAY_COL       // The UIColor used for the range overlay.
  
  var penColor:           UIColor = PEN_COL                   // The UIColor used for the sparkline colour itself
  var penWidth:           CGFloat = DEFAULT_GRAPH_PEN_WIDTH   // Value used for the sparkline pen width
  
  var rangeOverlayLowerLimit: NSNumber?
  var rangeOverlayUpperLimit: NSNumber?
  
  var dataMinimum: NSNumber?
  var dataMaximum: NSNumber?
  
  var dataSource: SparkLineDataSource?
  

  init(data: [NSNumber], label: String) {
    initialize( data, label: label)
  }
  
}

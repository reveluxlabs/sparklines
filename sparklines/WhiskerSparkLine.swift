//
//  WhiskerSparkLine.swift
//  sparklines
//
//  Created by Jim Holt on 9/6/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

struct WhiskerSparkLine: WhiskerSparkLinePlotter {

  var dataValues:              [NSNumber]?                             // Array of NSNumber values to display
  var labelText:               String?                                 // Text to be displayed beside the graph data
  var labelFont:               String  = LABEL_FONT
  var labelColor:              UIColor = DEFAULT_LABEL_COL             // Color of the label text (default: dark gray)
  var centerSparkLine:         Bool    = true                          // Enable centering of the sparkline in the view
  var showLabel:               Bool    = true                          // Enable display of the value (default: YES).
  var currentValueFormat:      String  = "%.1f"                        // The format of the value
  var showHighlightOverlay:    Bool    = false                         // Enable the display of the highlight overlay (default: NO).
  var highlightOverlayColor:   UIColor = DEFAULT_HIGHLIGHT_OVERLAY_COL // The UIColor used for the range overlay.
  var penColor:                UIColor = PEN_COL                       // Sparkline color itself
  var penWidth:                CGFloat = DEFAULT_GRAPH_PEN_WIDTH       // Sparkline pen width
  var xIncrement:              CGFloat = 2.0                           // For the whisker view, xIncrement is set, not calculated.
  var longestRun:              Int?    = 0                             // Longest run of whiskers from data source, used for value

  var whiskerColor:            UIColor = UIColor.blackColor()
  var highlightedWhiskerColor: UIColor = UIColor(red:0.99, green:0.14, blue:0.22, alpha:1.0) // scarlet
  var tickWidth:               CGFloat = DEFAULT_TICK_PEN_WIDTH
  var tickColor:               UIColor = UIColor(red:245/255, green:245/255, blue:245/255, alpha:0.1)
  
  var dataMinimum:             NSNumber?
  var dataMaximum:             NSNumber?
  
  var dataSource: WhiskerSparkLineDataSource? {
    didSet {
      longestRun = dataSource!.longestRun
    }
  }
  
  init(data: [NSNumber], label: String) {
    dataValues = data
    labelText = label
  }
}
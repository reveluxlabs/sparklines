//
//  PlotSpace.swift
//  sparklines
//
//  Created by Jim Holt on 9/2/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

struct PlotSpace {
  
  // calculate the view fraction that will be the graph
  var graphSize: CGFloat {
    get {
      return (fullWidth * 0.95) - textWidth!
    }
  }

  // calculate the view fraction that will be the graph
  var graphFrac: CGFloat {
    get {
      return graphSize / fullWidth
    }
  }
  var textWidth: CGFloat?
  
  // calculate the graph area and X & Y widths and scales
  var dataMin: Float
  var dataMax: Float
  
  let fullWidth:        CGFloat
  let fullHeight:       CGFloat
  var sparkWidth:       CGFloat {
    get {
      return (fullWidth  - (2 * GRAPH_X_BORDER)) * graphFrac
    }
  }
  var sparkHeight:      CGFloat {
    get {
      return fullHeight - (2 * GRAPH_Y_BORDER)
    }
  }
  let maxWhiskerHeight: CGFloat
  var xOffsetToCenter:  CGFloat = 0.5
  var xInc:             CGFloat? = 0.0
  var numberOfPoints:   Int?     = 0
  
  // defaults: upper and lower graph bounds are data maximum and minimum, respectively
  var graphMax: Float
  var graphMin: Float
  
  init( bounds: CGRect, dataMinimum: Float, dataMaximum: Float) {
    
    fullWidth  = CGRectGetWidth(bounds)
    fullHeight = CGRectGetHeight(bounds)
    
    maxWhiskerHeight = 10.0
    
    dataMin = dataMinimum
    dataMax = dataMaximum
    
    // defaults: upper and lower graph bounds are data maximum and minimum, respectively
    graphMax = dataMax
    graphMin = dataMin
  }
}


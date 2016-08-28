//
//  SparkLineViewProtocol.swift
//  sparklines
//
//  Created by Jim Holt on 8/27/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

protocol SparkLineViewProtocol {
  
  var rangeOverlayLowerLimit:    NSNumber? {get set}
  var rangeOverlayUpperLimit:    NSNumber? {get set}
  var dataMinimum:               NSNumber? {get set}
  var dataMaximum:               NSNumber? {get set}

  func initialize(data: [NSNumber], label: String)
  func computeRanges(dataValues: [NSNumber])
  func configureView()
  func computeMaxMin(values: [NSNumber]) -> (max: NSNumber?, min: NSNumber?)
  func frameForText( text: String, sizeWithFont font: UIFont, constrainedToSize maxSize: CGSize, lineBreakMode: NSLineBreakMode ) -> CGSize
  
  func drawRect(rect: CGRect)
  func drawSparkline( labelText: String, bounds: CGRect, dataMinimum: Float, dataMaximum: Float, dataValues: [NSNumber], context: CGContextRef )
  func drawLabelIfNeeded( labelText: String?, dataValues: [NSNumber], context: CGContextRef) -> CGSize
    
  func yPlotValue(maxHeight: Float, yInc: Float, val: Float, offset: Float, penWidth: Float) -> CGFloat
}

extension SparkLineViewProtocol where Self: SparkLineView {
  
//  func initialize(data: [NSNumber], label: String) {
//    dataValues = data
//    labelText = label
//    computeRanges(dataValues!)
//    configureView()
//    self.setNeedsDisplay()
//  }
//
//  func computeRanges(dataValues: [NSNumber]) {
//    let computedValues = computeMaxMin( dataValues )
//    dataMaximum = computedValues.max
//    dataMinimum = computedValues.min
//    rangeOverlayUpperLimit = dataMaximum
//    rangeOverlayLowerLimit = dataMinimum
//  }
//  
//  // configures the defaults (used in init or when waking from a nib)
//  func configureView() {
//    
//    // ensure we redraw correctly when resized
//    self.contentMode = UIViewContentMode.Redraw
//    
//    // and we have a nice rounded shape...
//    self.layer.masksToBounds = true
//    self.layer.cornerRadius = 5.0
//  }
//
//  func frameForText( text: String, sizeWithFont font: UIFont, constrainedToSize maxSize: CGSize, lineBreakMode: NSLineBreakMode ) -> CGSize {
//    var paragraphStyle: NSMutableParagraphStyle
//    var attributes:     [String: AnyObject]
//    var textRect:       CGRect
//    
//    paragraphStyle = NSMutableParagraphStyle()
//    paragraphStyle.setParagraphStyle(NSParagraphStyle.defaultParagraphStyle())
//    paragraphStyle.lineBreakMode = lineBreakMode;
//    
//    attributes = [NSFontAttributeName           : font,
//                  NSParagraphStyleAttributeName : paragraphStyle
//    ]
//    
//    
//    textRect = text.boundingRectWithSize(maxSize,
//                                         options:NSStringDrawingOptions.UsesLineFragmentOrigin,
//                                         attributes:attributes,
//                                         context:nil)
//    
//    return textRect.size;
//  }
//
//  // draws all the elements of this view
//  func drawRect(rect: CGRect) {
//    
//    let context = UIGraphicsGetCurrentContext()
//    
//    drawSparkline(labelText!,
//                  bounds: self.bounds,
//                  dataMinimum: dataMinimum!.floatValue,
//                  dataMaximum: dataMaximum!.floatValue,
//                  dataValues:  dataValues!,
//                  context:     context!)
//  }
//
}
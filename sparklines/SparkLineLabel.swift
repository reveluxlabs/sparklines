//
//  SparkLineLabel.swift
//  sparklines
//
//  Created by Jim Holt on 9/2/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

struct SparkLineLabel {
  let bounds:                    CGRect
  let count:                     Int
  let labelText:                 String?
  let labelFont:                 String
  let showCurrentValue:          Bool
  let currentValueColor:         UIColor
  let currentValueFormat:        String
  
  let sparkValue:                NSNumber?
  let maxTextWidth:              CGFloat
  var whiskerTextStartX:         CGFloat?
  var xInc:                      CGFloat?
  
  var graphText: String {
    get {
      return labelText == nil ? "not set" : String(UTF8String: labelText!)!
    }
  }
  
  var formattedGraphText: String?
  
  var formattedLabelValue: String {
    get {
      return " ".stringByAppendingFormat(currentValueFormat, sparkValue!.floatValue )
    }
  }
  
  var defaultLabelFont: UIFont? {
    get {
      return UIFont(name:labelFont, size:DEFAULT_FONT_SIZE)
    }
  }
  
  // calculate the width the text would take with the specified font
  var textSize: CGSize {
    get {
      return frameForText(formattedGraphText!,
                          sizeWithFont:defaultLabelFont!,
                          constrainedToSize:CGSizeMake(maxTextWidth, DEFAULT_FONT_SIZE+4),
                          lineBreakMode:NSLineBreakMode.ByClipping)
      
    }
  }
  var actualFontSize: CGFloat {
    get {
      return textSize.width <= (MAX_TEXT_FRAC * bounds.size.width) ? DEFAULT_FONT_SIZE : MIN_FONT_SIZE
    }
  }
  
  var textStartX: CGFloat  {
    get {
      return (CGRectGetWidth(self.bounds) * 0.975) - textSize.width
    }
  }
  
  var textStartY: CGFloat  {
    get {
      return CGRectGetMidY(self.bounds) - (textSize.height / 2.0)
    }
  }
  
  var selectedFont: UIFont? {
    get {
      return UIFont(name:labelFont, size:actualFontSize)
    }
  }
  
  var attributes: [String : AnyObject]? {
    get {
      return [ NSFontAttributeName : selectedFont! ]
    }
  }
  
  var labelDrawnSize: CGSize {
    get {
      return frameForText(labelText!,
                          sizeWithFont:selectedFont!,
                          constrainedToSize:CGSizeMake(maxTextWidth, actualFontSize+4),
                          lineBreakMode:NSLineBreakMode.ByClipping)
    }
  }
  
  var valueDrawnSize: CGSize {
    get {
      return frameForText(formattedLabelValue,
                          sizeWithFont:selectedFont!,
                          constrainedToSize:CGSizeMake(maxTextWidth, actualFontSize+4),
                          lineBreakMode:NSLineBreakMode.ByClipping)
    }
  }
  init( bounds: CGRect, count: Int, text: String, font: String, value: NSNumber, showValue: Bool, valueColor: UIColor, valueFormat: String) {
    self.bounds        = bounds
    self.count         = count
    maxTextWidth       = CGRectGetWidth(bounds) * MAX_TEXT_FRAC
    labelText          = text
    labelFont          = font
    sparkValue         = value
    showCurrentValue   = showValue
    currentValueColor  = valueColor
    currentValueFormat = valueFormat
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



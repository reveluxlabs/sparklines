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
  var showValue:                 Bool
  let currentValueColor:         UIColor
  let currentValueFormat:        String

  var reverse:                   Bool = false
  
  let sparkValue:                NSNumber?
  let maxTextWidth:              CGFloat
  var whiskerTextStartX:         CGFloat?
  var xInc:                      CGFloat?
  
  var graphText: String {
    get {
      return labelText == nil ? "not set" : String(validatingUTF8: labelText!)!
    }
  }
  
  var formattedGraphText: String {
    get {
      var text = graphText
      if showValue {
        text = reverse ? formattedLabelValue + text : text + formattedLabelValue
      }
      
      return text
    }
  }
  
  var formattedLabelValue: String {
    get {
      let head = reverse ? "" : " "
      return head.appendingFormat(currentValueFormat, sparkValue!.floatValue )
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
      return frameForText(formattedGraphText,
                          sizeWithFont:defaultLabelFont!,
                          constrainedToSize:CGSize(width: maxTextWidth, height: DEFAULT_FONT_SIZE+4),
                          lineBreakMode:NSLineBreakMode.byClipping)
      
    }
  }
  var actualFontSize: CGFloat {
    get {
      return textSize.width <= (MAX_TEXT_FRAC * bounds.size.width) ? DEFAULT_FONT_SIZE : MIN_FONT_SIZE
    }
  }
  
  var textStartX: CGFloat  {
    get {
      return (self.bounds.width * 0.975) - textSize.width
    }
  }
  
  var textStartY: CGFloat  {
    get {
      return self.bounds.midY - (textSize.height / 2.0)
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
                          constrainedToSize:CGSize(width: maxTextWidth, height: actualFontSize+4),
                          lineBreakMode:NSLineBreakMode.byClipping)
    }
  }
  
  var valueDrawnSize: CGSize {
    get {
      return frameForText(formattedLabelValue,
                          sizeWithFont:selectedFont!,
                          constrainedToSize:CGSize(width: maxTextWidth, height: actualFontSize+4),
                          lineBreakMode:NSLineBreakMode.byClipping)
    }
  }
  init( bounds: CGRect, count: Int, text: String, font: String, value: NSNumber, showValue: Bool, valueColor: UIColor, valueFormat: String, reverse: Bool) {
    self.bounds        = bounds
    self.count         = count
    maxTextWidth       = bounds.width * MAX_TEXT_FRAC
    labelText          = text
    labelFont          = font
    sparkValue         = value
    self.showValue     = showValue
    currentValueColor  = valueColor
    currentValueFormat = valueFormat
    self.reverse  = reverse
  }
  
  func frameForText( _ text: String, sizeWithFont font: UIFont, constrainedToSize maxSize: CGSize, lineBreakMode: NSLineBreakMode ) -> CGSize {
    var paragraphStyle: NSMutableParagraphStyle
    var attributes:     [String: AnyObject]
    var textRect:       CGRect
    
    paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.setParagraphStyle(NSParagraphStyle.default)
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    attributes = [NSFontAttributeName           : font,
                  NSParagraphStyleAttributeName : paragraphStyle
    ]
    
    
    textRect = text.boundingRect(with: maxSize,
                                         options:NSStringDrawingOptions.usesLineFragmentOrigin,
                                         attributes:attributes,
                                         context:nil)
    
    return textRect.size;
  }
}



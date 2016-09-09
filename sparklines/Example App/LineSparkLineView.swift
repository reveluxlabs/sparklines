//
//  LineSparkLineView.swift
//  sparklines
//
//  Created by Jim Holt on 8/25/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

public class LineSparkLineView: UIView {
  
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
    
    lineSpark!.draw( self.bounds, renderer: context! )
  }

}

//
//  Renderer.swift
//  sparklines
//
//  Created by Jim Holt on 9/5/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

protocol Renderer {
  func moveTo(position: CGPoint)
  func lineTo(position: CGPoint)
  
  func saveState()
  func restoreState()
  func fillRect( rect: CGRect )
  func fillEllipse( rect: CGRect )
  func setLineWidth( width: CGFloat )
  func setStroke( color: UIColor )
  func setFill(  color: UIColor )
  func beginPath()
  func strokePath()
  func closePath()
}

extension CGContext : Renderer {
  func moveTo(position: CGPoint) {
    CGContextMoveToPoint(self, position.x, position.y)
  }

  func lineTo(position: CGPoint) {
    CGContextAddLineToPoint(self, position.x, position.y)
  }

  func saveState(){
    CGContextSaveGState(self)
  }

  func restoreState(){
    CGContextRestoreGState(self)
  }

  func fillRect( rect: CGRect ){
    CGContextFillRect(self, rect)
  }

  func fillEllipse( rect: CGRect ){
    CGContextFillEllipseInRect(self, rect)
  }

  func setLineWidth( width: CGFloat ){
    CGContextSetLineWidth(self, width)
  }

  func setStroke( color: UIColor ){
    CGContextSetStrokeColorWithColor(self, color.CGColor)
  }
  
  func setFill( color: UIColor ){
    CGContextSetFillColorWithColor(self, color.CGColor)
  }
  
  func beginPath(){
    CGContextBeginPath(self)
  }

  func strokePath(){
    CGContextStrokePath(self)
  }

  func closePath(){
    CGContextClosePath(self)
  }

}

//
//  Renderer.swift
//  sparklines
//
//  Created by Jim Holt on 9/5/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

protocol Renderer {
  func moveTo(_ position: CGPoint)
  func lineTo(_ position: CGPoint)
  
  func saveState()
  func restoreState()
  func fillRect( _ rect: CGRect )
  func fillEllipse( _ rect: CGRect )
  func setLineWidth( _ width: CGFloat )
  func setStroke( _ color: UIColor )
  func setFill(  _ color: UIColor )
  func beginPath()
  func strokePath()
  func closePath()
}

extension CGContext : Renderer {
  func moveTo(_ position: CGPoint) {
    self.move(to: CGPoint(x: position.x, y: position.y))
  }

  func lineTo(_ position: CGPoint) {
    self.addLine(to: CGPoint(x: position.x, y: position.y))
  }

  func saveState(){
    self.saveGState()
  }

  func restoreState(){
    self.restoreGState()
  }

  func fillRect( _ rect: CGRect ){
    self.fill(rect)
  }

  func fillEllipse( _ rect: CGRect ){
    self.fillEllipse(in: rect)
  }

//  func setLineWidth( _ width: CGFloat ){
//    self.setLineWidth(width)
//  }

  func setStroke( _ color: UIColor ){
    self.setStrokeColor(color.cgColor)
  }
  
  func setFill( _ color: UIColor ){
    self.setFillColor(color.cgColor)
  }
  
//  func beginPath(){
//    self.beginPath()
//  }
//
//  func strokePath(){
//    self.strokePath()
//  }
//
//  func closePath(){
//    self.closePath()
//  }

}

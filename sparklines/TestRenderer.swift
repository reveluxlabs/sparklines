//
//  TestRenderer.swift
//  sparklines
//
//  Created by Jim Holt on 9/5/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import CoreGraphics

struct TestRenderer : Renderer {
  func moveTo(p: CGPoint) { print("moveTo(\(p.x), \(p.y))") }
  
  func lineTo(p: CGPoint) { print("lineTo(\(p.x), \(p.y))") }
  
  func saveState() { print("saveState()") }
  
  func restoreState() { print("restoreState()") }
  
  func fillRect( rect: CGRect ) { print("fillRect(\(rect))") }
  
  func fillEllipse( rect: CGRect ) { print("fillEllipse(\(rect))") }
  
  func setLineWidth( width: CGFloat )  { print("setLineWidth(\(width))") }
  
  func beginPath() { print("beginPath()") }
  
  func strokePath() { print("strokePath()") }
  
  func closePath() { print("closePath()") }
  
}

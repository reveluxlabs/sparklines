//
//  TestRenderer.swift
//  sparklines
//
//  Created by Jim Holt on 9/5/16.
//  Copyright © 2016 Revelux Labs LLC. All rights reserved.
//

import UIKit

class TestRenderer : Renderer {
  var commands: [String] = []
  
  func appendAndPrint( _ cmd: String ) {
    commands.append(cmd)
    print(cmd)
  }
  
  func moveTo(_ p: CGPoint) { appendAndPrint("moveTo(\(p.x), \(p.y))") }
  
  func lineTo(_ p: CGPoint) { appendAndPrint("lineTo(\(p.x), \(p.y))") }
  
  func saveState() { appendAndPrint("saveState()") }
  
  func restoreState() { appendAndPrint("restoreState()") }
  
  func fillRect( _ rect: CGRect ) { appendAndPrint("fillRect(\(rect))") }
  
  func fillEllipse( _ rect: CGRect ) { appendAndPrint("fillEllipse(\(rect))") }
  
  func setLineWidth( _ width: CGFloat ) { appendAndPrint("setLineWidth(\(width))") }
  
  func setStroke( _ color: UIColor ) { appendAndPrint("setStroke(\(color))") }
  
  func setFill( _ color: UIColor ) { appendAndPrint("setFill(\(color))") }
  
  func beginPath() { appendAndPrint("beginPath()") }
  
  func strokePath() { appendAndPrint("strokePath()") }
  
  func closePath() { appendAndPrint("closePath()") }
  
}

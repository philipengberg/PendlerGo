//
//  UIImage+Utilities.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
    
    static func imageNamed(_ name: String, coloredWithColor color: UIColor,  blendMode: CGBlendMode) -> UIImage {
    // load the image
    let baseImage = UIImage(named: name)!
        
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContextWithOptions(baseImage.size, false, baseImage.scale);
    
    // get a reference to that context we created
    let context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    color.setFill()
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    context?.translateBy(x: 0, y: baseImage.size.height);
    context?.scaleBy(x: 1, y: -1);
    
    // set the blend mode to color burn, and the original image
    context?.setBlendMode(blendMode);
    context?.setAlpha(1.0);
    let rect = CGRect(x: 0, y: 0, width: baseImage.size.width, height: baseImage.size.height);
    context?.draw(baseImage.cgImage!, in: rect);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    context?.clip(to: rect, mask: baseImage.cgImage!);
    context?.addRect(rect);
    context?.drawPath(using: CGPathDrawingMode.fill);
    
    // generate a new UIImage from the graphics context we drew onto
    let coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg!
    }
    
}

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
    
    static func imageNamed(name: String, coloredWithColor color: UIColor,  blendMode: CGBlendMode) -> UIImage {
    // load the image
    let baseImage = UIImage(named: name)!
        
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContextWithOptions(baseImage.size, false, baseImage.scale);
    
    // get a reference to that context we created
    let context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    color.setFill()
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, baseImage.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, blendMode);
    CGContextSetAlpha(context, 1.0);
    let rect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    CGContextDrawImage(context, rect, baseImage.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, baseImage.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, CGPathDrawingMode.Fill);
    
    // generate a new UIImage from the graphics context we drew onto
    let coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg
    }
    
}
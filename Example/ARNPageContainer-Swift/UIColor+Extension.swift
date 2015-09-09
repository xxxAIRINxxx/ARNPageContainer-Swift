//
//  UIColor+Extension.swift
//  ARNPageContainer-Swift
//
//  Created by xxxAIRINxxx on 2015/09/09.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

public struct RGBA {
    var red : CGFloat = 0.0
    var green : CGFloat = 0.0
    var blue : CGFloat = 0.0
    var alpha  : CGFloat = 0.0
}

public extension UIColor {
    
    public func imageWithColor() -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, self.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func getRGBAStruct() -> RGBA {
        let components = CGColorGetComponents(self.CGColor)
        let colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))
        
        if colorSpaceModel.value == kCGColorSpaceModelRGB.value && CGColorGetNumberOfComponents(self.CGColor) == 4 {
            return RGBA(
                red: components[0],
                green: components[1],
                blue: components[2],
                alpha: components[3]
            )
        } else if colorSpaceModel.value == kCGColorSpaceModelMonochrome.value && CGColorGetNumberOfComponents(self.CGColor) == 2 {
            return RGBA(
                red: components[0],
                green: components[0],
                blue: components[0],
                alpha: components[1]
            )
        } else {
            return RGBA()
        }
    }
}
//
//  CGFloatExtension.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/18/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

private let currentWidth = UIScreen.main.bounds.size.width
private let mockupWidth: CGFloat = 375

extension CGFloat {
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var adjustedByWidth: CGFloat {
        guard mockupWidth != currentWidth else {
            return self
        }
        return ceil(self * currentWidth / mockupWidth)
    }
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var restoredByWidth: CGFloat {
        guard mockupWidth != currentWidth else {
            return self
        }
        return ceil(self * mockupWidth / currentWidth)
    }
}

extension Float {
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var adjustedByWidth: Float {
        guard mockupWidth != currentWidth else {
            return self
        }
        return ceil(self * Float(currentWidth) / Float(mockupWidth))
    }
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var restoredByWidth: Float {
        guard mockupWidth != currentWidth else {
            return self
        }
        return ceil(self * Float(mockupWidth) / Float(currentWidth))
    }
}

extension Double {
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var adjustedByWidth: Double {
        guard mockupWidth != currentWidth else {
            return self
        }
        return ceil(self * Double(currentWidth) / Double(mockupWidth))
    }
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var restoredByWidth: Double {
        guard mockupWidth != currentWidth else {
            return self
        }
        return ceil(self * Double(mockupWidth) / Double(currentWidth))
    }
    
}

extension Int {
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var adjustedByWidth: Int {
        guard mockupWidth != currentWidth else {
            return self
        }
        return Int(CGFloat(self) * currentWidth / mockupWidth)
    }
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var restoredByWidth: Int {
        guard mockupWidth != currentWidth else {
            return self
        }
        return Int(CGFloat(self) * mockupWidth / currentWidth)
    }
    
}

extension CGSize {
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var adjustedByWidth: CGSize {
        guard mockupWidth != currentWidth else {
            return self
        }
        return CGSize(width: width.adjustedByWidth, height: height.adjustedByWidth)
    }
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var restoredByWidth: CGSize {
        guard mockupWidth != currentWidth else {
            return self
        }
        return CGSize(width: width.restoredByWidth, height: height.restoredByWidth)
    }
}

extension UIEdgeInsets {
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var adjustedByWidth: UIEdgeInsets {
        guard mockupWidth != currentWidth else {
            return self
        }
        return UIEdgeInsets(
            top: top.adjustedByWidth,
            left: left.adjustedByWidth,
            bottom: bottom.adjustedByWidth,
            right: right.adjustedByWidth
        )
    }
    
    /// Adjusted value by width of iPhone 6+ screen size to current screen size.
    var restoredByWidth: UIEdgeInsets {
        guard mockupWidth != currentWidth else {
            return self
        }
        return UIEdgeInsets(
            top: top.restoredByWidth,
            left: left.restoredByWidth,
            bottom: bottom.restoredByWidth,
            right: right.restoredByWidth
        )
    }
}

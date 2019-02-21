//
//  UIImageExtension.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/21/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

extension UIImageView {

    func clone() -> UIImageView {
        let newView = UIImageView()
        newView.image = self.image
        newView.highlightedImage = self.highlightedImage
        newView.animationImages = self.animationImages
        newView.highlightedAnimationImages = self.highlightedAnimationImages
        newView.animationDuration = self.animationDuration
        newView.animationRepeatCount = self.animationRepeatCount
        newView.isHighlighted = self.isHighlighted
        newView.tintColor = self.tintColor
        newView.transform = self.transform
        newView.bounds = self.bounds
        newView.layer.cornerRadius = self.layer.cornerRadius
        newView.layer.masksToBounds = self.layer.masksToBounds
        newView.contentMode = self.contentMode
        return newView
    }
    
}

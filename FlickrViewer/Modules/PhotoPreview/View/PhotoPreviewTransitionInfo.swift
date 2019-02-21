//
//  PhotoPreview.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/21/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

final class PhotoPreviewTransitionInfo: NSObject {
    
    private(set) var interactiveDismissalEnabled: Bool = true
    private(set) weak var startingView: UIImageView?
    private(set) weak var endingView: UIImageView?
    var duration: TimeInterval = 0.3
    
    init(interactiveDismissalEnabled: Bool, startingView: UIImageView?, endingView: UIImageView?) {
        super.init()
        self.commonInit(interactiveDismissalEnabled: interactiveDismissalEnabled,
                        startingView: startingView,
                        endingView: endingView)
    }
    
    convenience override init() {
        self.init(interactiveDismissalEnabled: true, startingView: nil, endingView: nil)
    }
    
    private func commonInit(interactiveDismissalEnabled: Bool,
                            startingView: UIImageView?,
                            endingView: UIImageView?) {
        
        self.interactiveDismissalEnabled = interactiveDismissalEnabled
        
        if let startingView = startingView {
            guard startingView.bounds != .zero else {
                assertionFailure("startingView has invalid geometry: \(startingView)")
                return
            }
            
            self.startingView = startingView
        }
        
        if let endingView = endingView {
            guard endingView.bounds != .zero else {
                self.endingView = nil
                assertionFailure("endingView has invalid geometry: \(endingView)")
                return
            }
            
            self.endingView = endingView
        }
    }
}

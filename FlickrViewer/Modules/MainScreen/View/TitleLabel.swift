//
//  TitleLabel.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/19/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

final class TitleLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attributedText = _attributedText
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.attributedText = _attributedText
    }
    
    private var _attributedText: NSAttributedString {
        get {
            let text = "Flickr Viewer"
            let attributedString = NSMutableAttributedString(string: text, attributes: nil)
            let firstWordRange = (attributedString.string as NSString).range(of: "Flickr")
            let lastWordRange = (attributedString.string as NSString).range(of: "Viewer")
            let fullRange = NSRange(location: 0, length: text.count)
            if let font = UIFont(name: Constants.fonts.boldItalic, size: Constraints.titleLabel.fontSize) {
                attributedString.addAttribute(.font, value: font, range: fullRange)
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
            attributedString.addAttribute(.kern, value: CGFloat(-1), range: fullRange)
            attributedString.addAttribute(.foregroundColor, value: Constants.colors.blue.stringToUIColor(), range: firstWordRange)
            attributedString.addAttribute(.foregroundColor, value: Constants.colors.pink.stringToUIColor(), range: lastWordRange)
            return attributedString
        }
    }
}

extension TitleLabel {
    enum Constraints {
        enum titleLabel {
            static let fontSize = CGFloat(17)
        }
    }
}

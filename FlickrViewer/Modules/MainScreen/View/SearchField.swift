//
//  SearchField.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/19/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit
import SnapKit

final class SearchField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private lazy var magnifier: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFill
        imgV.image = UIImage(named: "search")
        
        self.addSubview(imgV)
        imgV.snp.makeConstraints({ make in
            make.centerY.equalTo(self)
            make.left.equalTo(7)
            make.width.height.equalTo(14)
        })
        return imgV
    }()
    
    private func setup() {
        self.backgroundColor = Constants.colors.whiteSmoke.stringToUIColor()
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        magnifier.isHidden = false
        self.placeholder = "Search"
    }
    
    let padding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 5)
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    
}

//
//  SearchField.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/19/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit
import SnapKit

protocol SearchFieldDelegate: class {
    func search(_ text:String)
}

final class SearchField: UITextField, UITextFieldDelegate {
    
    weak var searchDelegate: SearchFieldDelegate?
    let padding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 5)
    
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
        imgV.image = UIImage(named: "search_grey")
        
        self.addSubview(imgV)
        imgV.snp.makeConstraints({ make in
            make.centerY.equalTo(self)
            make.left.equalTo(7)
            make.width.height.equalTo(18)
        })
        return imgV
    }()
    
    private func setup() {
        self.delegate = self
        self.returnKeyType = .search
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.backgroundColor = Constants.colors.whiteSmoke.uiColor
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        magnifier.isHidden = false
        self.placeholder = "Search"
    }
    
    
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.searchDelegate?.search(textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

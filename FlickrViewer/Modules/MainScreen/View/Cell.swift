//
//  Cell.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/19/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class Cell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private lazy var imageView: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFill
        imgV.clipsToBounds = true
        imgV.layer.cornerRadius = 12
        imgV.backgroundColor = Constants.colors.whiteSmoke.stringToUIColor()
        self.addSubview(imgV)
        
        imgV.snp.makeConstraints({ make in
            make.left.top.equalTo(self).offset(2)
            make.right.bottom.equalTo(self).offset(-2)
        })
        return imgV
    }()
    
    func setup(photo: MainModel.Photo) {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        setupShadow()
        guard let thumb = photo.thumb?.url, let url = URL(string: thumb) else { return }
        imageView.sd_setImage(with: url, placeholderImage: nil)
    }
    
    private func setupShadow() {
        backgroundColor = .clear // very important
        layer.masksToBounds = false
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor.black.cgColor
        
        // add corner radius on `contentView`
        contentView.layer.cornerRadius = 8
    }
}

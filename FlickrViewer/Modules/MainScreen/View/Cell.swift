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
        self.addSubview(imgV)
        
        imgV.snp.makeConstraints({ make in
            make.left.right.top.bottom.equalTo(self)
        })
        return imgV
    }()
    
    func setup(photo: MainModel.Photo) {
        self.backgroundColor = Constants.colors.whiteSmoke.stringToUIColor()
        guard let thumb = photo.thumb?.url, let url = URL(string: thumb) else { return }
        imageView.sd_setImage(with: url, placeholderImage: nil)
    }
}

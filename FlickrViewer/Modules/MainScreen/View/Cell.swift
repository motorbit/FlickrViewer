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
    
    var photo: MainModel.Photo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    lazy var imageView: UIImageView = {
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
    
    private lazy var uploadedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.boldItalic, size: 8)
        self.info.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.right.bottom.equalTo(self.info).offset(-8)
        })
        return lbl
    }()
    
    private lazy var takenLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.boldItalic, size: 8)
        self.info.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.bottom.equalTo(self.info).offset(-8)
            make.left.equalTo(self.info).offset(8)
        })
        return lbl
    }()
    
    private lazy var owner: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.boldItalic, size: 12)
        lbl.textColor = Constants.colors.pink.stringToUIColor()
        self.info.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.top.left.equalTo(self.info).offset(8)
            make.right.equalTo(self.info).offset(-8)
        })
        return lbl
    }()
    
    private lazy var title: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.boldItalic, size: 10)
        lbl.textColor = Constants.colors.blue.stringToUIColor()
        lbl.numberOfLines = 4
        self.info.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.left.equalTo(self.info).offset(8)
            make.right.equalTo(self.info).offset(-8)
            make.top.equalTo(self.owner.snp.bottom).offset(8)
            make.bottom.greaterThanOrEqualTo(self.takenLabel.snp.top).offset(-8)
        })
        return lbl
    }()
    
    private lazy var info: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.backgroundColor = Constants.colors.whiteSmoke.stringToUIColor().withAlphaComponent(0.5)
        self.addSubview(view)
        
        view.snp.makeConstraints({ make in
            make.right.bottom.equalTo(self).offset(-2)
            make.left.equalTo(self).offset(2)
            make.height.equalTo(100)
        })
        
        return view
    }()
    
    
    func setup(photo: MainModel.Photo) {
        self.photo = photo
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        setupShadow()
        guard let thumb = photo.thumb?.url, let url = URL(string: thumb) else { return }
        imageView.sd_setImage(with: url, placeholderImage: nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if let uploaded = photo.uploaded {
            uploadedLabel.text = dateFormatter.string(from: uploaded)
        }
        if let taken = photo.taken {
            takenLabel.text = dateFormatter.string(from: taken)
        }
        title.text = photo.title
        owner.text = photo.owner
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

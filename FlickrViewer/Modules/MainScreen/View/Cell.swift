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


final class Cell: UICollectionViewCell {
    
    var photo: MainModel.Photo?
    
    static let infoViewHeight: CGFloat = 75
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        info.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
    }
    
    // MARK: UI elements
    
    lazy var imageView: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFill
        self.addSubview(imgV)
        
        imgV.snp.makeConstraints({ make in
            make.left.top.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self.info.snp.top).offset(2)
        })
        return imgV
    }()
    
    private lazy var uploadedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.regular, size: 8)
        lbl.textColor = Constants.colors.white.uiColor
        self.info.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.right.bottom.equalTo(self.info).offset(-8)
        })
        return lbl
    }()
    
    private lazy var takenLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.regular, size: 8)
        lbl.textColor = Constants.colors.white.uiColor
        self.info.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.bottom.equalTo(self.info).offset(-8)
            make.left.equalTo(self.info).offset(8)
        })
        return lbl
    }()
    
    private lazy var owner: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.regular, size: 12)
        lbl.textColor = Constants.colors.white.uiColor
        self.info.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.top.left.equalTo(self.info).offset(8)
            make.right.equalTo(self.info).offset(-8)
        })
        return lbl
    }()
    
    private lazy var title: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.regular, size: 10)
        lbl.textColor = Constants.colors.white.uiColor
        lbl.numberOfLines = 2
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
        view.backgroundColor = Constants.colors.black.uiColor.withAlphaComponent(0.8)
        self.addSubview(view)
        
        view.snp.makeConstraints({ make in
            make.right.bottom.equalTo(self)
            make.left.equalTo(self)
            make.height.equalTo(Cell.infoViewHeight)
        })
        
        return view
    }()
    
    // MARK: Setup
    
    func setup(photo: MainModel.Photo) {
        self.photo = photo
        setupShadow()
        guard let thumb = photo.thumb?.url, let url = URL(string: thumb) else { return }
        
        if let origin = getOriginFromCache() {
            imageView.image = origin
        } else {
            imageView.sd_setImage(with: url, placeholderImage: nil)
        }
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
        self.bringSubviewToFront(imageView)
    }
    
    private func getOriginFromCache() -> UIImage? {
        if let origLink = photo?.orig?.url, let originUrl = URL(string: origLink) {
            if let image = SDImageCache.shared().imageFromDiskCache(forKey: originUrl.absoluteString) {
                return image
            }
            
            if let image = SDImageCache.shared().imageFromMemoryCache(forKey: originUrl.absoluteString) {
                return image
            }
        }
        return nil
    }
    
    private func setupShadow() {
        backgroundColor = .clear // very important
        layer.masksToBounds = false
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = Constants.colors.black.uiColor.cgColor
        
        // add corner radius on `contentView`
        contentView.layer.cornerRadius = 8
    }
    
    
}

//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//


import UIKit
import SnapKit

final class MainViewController: UIViewController, MainViewInput {
    
    var presenter: MainPresenterProtocol!
    
    private var ds = CollectionViewDS()
    
    private lazy var titleLabel: UILabel = {
        let lbl = TitleLabel()
        self.view.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view.safeArea.top).offset(Constraints.titleLabel.top)
            make.width.equalTo(Constraints.titleLabel.width)
        })
        return lbl
    }()
    
    private lazy var searchField: UITextField = {
        let field = SearchField()
        self.view.addSubview(field)
        
        field.snp.makeConstraints({ make in
            make.left.equalTo(Constraints.searchField.padding)
            make.right.equalTo(-Constraints.searchField.padding)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(Constraints.searchField.padding)
            make.height.equalTo(Constraints.searchField.height)
        })
        return field
    }()
    
    private lazy var separator: UIView = {
        let _view = UIView()
        _view.backgroundColor = Constants.colors.whiteSmoke.stringToUIColor()
        self.view.addSubview(_view)
        
        _view.snp.makeConstraints({ make in
            make.height.equalTo(Constraints.separator.height)
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.searchField.snp.bottom).offset(Constraints.separator.top)
        })
        return _view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = CollectionView()
        cv.setup(ds)
        self.view.addSubview(cv)
        
        cv.snp.makeConstraints({ make in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.separator.snp.bottom).offset(Constraints.collection.top)
        })
        
        return cv
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = Constants.colors.white.stringToUIColor()
        self.presenter.showed()
        self.separator.isHidden = false
    }
    
    func setup(model: MainModel) {
        ds.model = model
        collectionView.reloadData()
    }
}

extension MainViewController {
    enum Constraints {
        enum titleLabel {
            static let top = CGFloat(11)
            static let width = CGFloat(100)
        }
        
        enum searchField {
            static let padding = CGFloat(15)
            static let height = CGFloat(36)
        }
        
        enum separator {
            static let height = CGFloat(1)
            static let top = CGFloat(10)
        }
        
        enum collection {
            static let top = CGFloat(8)
        }
    }
}



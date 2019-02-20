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
        cv.setup(ds, delegate: self)
        self.view.addSubview(cv)
        
        cv.snp.makeConstraints({ make in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.separator.snp.bottom)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        })
        
        return cv
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = Constants.colors.white.stringToUIColor()
        self.presenter.showed()
        self.separator.isHidden = false
        addTapGesture()
        
    }
    
    private func addTapGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnScreen(recognizer:)))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func setup(model: MainModel) {
        if ds.model == nil {
            ds.model = model
        } else {
            ds.model?.photos.append(contentsOf: model.photos)
        }
        collectionView.reloadData()
    }
    
    @objc private func tapOnScreen(recognizer: UITapGestureRecognizer) {
        self.searchField.endEditing(true)
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

extension MainViewController: CollectionViewProtocol {
    func scrolled(_ to: Int) {
        print(to)
        guard let model = ds.model else { return }
        if model.photos.count < model.total, model.photos.count - 25 <= to {
            self.presenter.getNext()
        }
    }
    
    func selected(_ photo: MainModel.Photo) {
        self.presenter.selected(photo: photo)
    }
}

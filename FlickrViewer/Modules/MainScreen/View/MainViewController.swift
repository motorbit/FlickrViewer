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
    
    // MARK: Public properties
    
    var presenter: MainPresenterProtocol!
    
    // MARK: Private properties
    
    private var ds = CollectionViewDS()
    private var isRefreshing = false
    
    // MARK: UI elements
    
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Constants.colors.blue.uiColor
        rc.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        return rc
    }()
    
    private lazy var totalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.boldItalic, size: 12)
        self.view.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.right.equalTo(self.view).offset(-Constraints.totalLabel.right)
            make.centerY.equalTo(self.titleLabel)
        })
        return lbl
    }()
    
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
        field.searchDelegate = self
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
        _view.backgroundColor = Constants.colors.whiteSmoke.uiColor
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
        cv.refreshControl = refreshControl
        cv.setup(ds, delegate: self)
        self.view.addSubview(cv)
        
        cv.snp.makeConstraints({ make in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.separator.snp.bottom)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        })
        
        return cv
    }()
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        self.view.backgroundColor = Constants.colors.white.uiColor
        self.presenter.fetchData()
        collectionView.isHidden = false
        addTapGesture()
    }
    
    // MARK: Setup
    func setup(model: MainModel) {
        self.refreshControl.endRefreshing()
        totalLabel.text = "\(model.total)"
        if ds.model == nil {
            ds.model = model
        } else {
            if isRefreshing || model.isNeedScroll {
                ds.model = model
            } else {
                ds.model?.photos.append(contentsOf: model.photos)
            }
        }
        collectionView.reloadData()
        isRefreshing = false
        if model.isNeedScroll {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    // MARK: Actions
    
    @objc private func refreshWeatherData(_ sender: Any) {
        isRefreshing = true
        self.presenter.fetchData()
    }
    
    private func addTapGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnScreen(recognizer:)))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func tapOnScreen(recognizer: UITapGestureRecognizer) {
        self.searchField.endEditing(true)
    }
    
    func showAlertOk(title: String, message: String) {
        self.refreshControl.endRefreshing()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "ok", style: .default)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension MainViewController {
    enum Constraints {
        enum totalLabel {
            static let right = CGFloat(15)
        }
        
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
        guard let model = ds.model else { return }
        if model.photos.count < model.total, model.photos.count - 25 <= to {
            self.presenter.fetchMore()
        }
    }
    
    func selected(_ photo: MainModel.Photo, imageView: UIImageView) {
        self.presenter.selected(photo: photo, imageView: imageView) { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }
}

extension MainViewController: SearchFieldDelegate {
    
    func search(_ text: String) {
        self.presenter.search(text)
    }
    
    
}

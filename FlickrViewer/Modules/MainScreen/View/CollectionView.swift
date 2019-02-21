//
//  CollectionView.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/19/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

protocol CollectionViewProtocol: class {
    func scrolled(_ to: Int)
    func selected(_ photo: MainModel.Photo, imageView: UIImageView)
}

final class CollectionView: UICollectionView {
    
    private let width = (UIScreen.main.bounds.width - 8 * 3) / 2
    private weak var interactionDelegate: CollectionViewProtocol?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: CGRect.zero, collectionViewLayout: CollectionView.layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: CGRect.zero, collectionViewLayout: CollectionView.layout)
        setup()
    }
    
    func setup(_ ds: UICollectionViewDataSource, delegate: CollectionViewProtocol? = nil) {
        self.dataSource = ds
        self.delegate = self
        self.alwaysBounceVertical = true
        self.bounces = true
        self.interactionDelegate = delegate
        if let layout = self.collectionViewLayout as? CollectionViewLayout {
            layout.delegate = self
        }
    }
    
    private func setup() {
        self.backgroundColor = Constants.colors.white.stringToUIColor()
        self.register(Cell.self, forCellWithReuseIdentifier: "cell")
    }
    
    private static var layout: UICollectionViewLayout {
        get {
            let layout = CollectionViewLayout()
            return layout
        }
    }
}

extension CollectionView: CollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        guard let ds = collectionView.dataSource as? CollectionViewDS,
              let size = ds.model?.photos[indexPath.row].thumb?.size
        else {
            return 0
        }
        
        let multiple = size.width / width
        let height = size.height / multiple + 100
        
        return height
    }
}

extension CollectionView: UICollectionViewDelegate {
   
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.interactionDelegate?.scrolled(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let ds = collectionView.dataSource as? CollectionViewDS,
              let photo = ds.model?.photos[indexPath.row]
        else { return }
        if let cell = collectionView.cellForItem(at: indexPath) as? Cell {
            self.interactionDelegate?.selected(photo, imageView: cell.imageView)
        }
    }
}

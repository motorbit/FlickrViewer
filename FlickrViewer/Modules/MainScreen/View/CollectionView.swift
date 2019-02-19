//
//  CollectionView.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/19/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

final class CollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let width = (UIScreen.main.bounds.width - 8 * 3) / 2
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: CGRect.zero, collectionViewLayout: CollectionView.layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: CGRect.zero, collectionViewLayout: CollectionView.layout)
        setup()
    }
    
    func setup(_ ds: UICollectionViewDataSource) {
        self.dataSource = ds
        self.delegate = self
    }
    
    private func setup() {
        self.backgroundColor = Constants.colors.white.stringToUIColor()
        self.register(Cell.self, forCellWithReuseIdentifier: "cell")
    }
    
    private static var layout: UICollectionViewFlowLayout {
        get {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            layout.minimumLineSpacing = 8.0
            layout.minimumInteritemSpacing = 8.0
            return layout
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let ds = collectionView.dataSource as? CollectionViewDS,
              let size = ds.model?.photos[indexPath.row].thumb.size
        else {
            return CGSize.zero
        }
        let multiple = size.width / width
        let height = size.height / multiple
        
        return CGSize(width: width, height: height)
    }

}

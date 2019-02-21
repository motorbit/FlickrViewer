//
//  CollectionViewDataSource.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/19/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

final class CollectionViewDS: NSObject, UICollectionViewDataSource {
    
    var model: MainModel?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.photos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                            for: indexPath) as? Cell,
              let photo = model?.photos[indexPath.row]
        else { return UICollectionViewCell() }
        cell.setup(photo: photo)
        return cell
    }

}



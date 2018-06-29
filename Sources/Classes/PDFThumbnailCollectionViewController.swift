//
//  PDFThumbnailCollectionViewController.swift
//  PDFReader
//
//  Created by Ricardo Nunez on 7/9/16.
//  Copyright © 2016 AK. All rights reserved.
//

import UIKit

/// Delegate that is informed of important interaction events with the current thumbnail collection view
protocol PDFThumbnailControllerDelegate: class {
    /// User has tapped on thumbnail
    func didSelectIndexPath(_ indexPath: IndexPath)
}

/// Bottom collection of thumbnails that the user can interact with
internal final class PDFThumbnailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    /// Current document being displayed
    var document: PDFDocument!
    
    /// Current page index being displayed
    var currentPageIndex: Int = 0 {
        didSet {
            guard let collectionView = collectionView else { return }
            if currentPageIndex < collectionView.numberOfItems(inSection: 0) {
                let curentPageIndexPath = IndexPath(row: currentPageIndex, section: 0)
                if !collectionView.indexPathsForVisibleItems.contains(curentPageIndexPath) {
                    collectionView.scrollToItem(at: curentPageIndexPath, at: .centeredHorizontally, animated: true)
                }
            }
            collectionView.reloadData()
        }
    }
    
    /// Calls actions when certain cells have been interacted with
    weak var delegate: PDFThumbnailControllerDelegate?
    
    /// Small thumbnail image representations of the pdf pages
    private var pageImages: [UIImage]? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// UI properties
    var uiProperties: PDFThumbnailUIProperties?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let document = self?.document {
                document.allPageImages(callback: { (images) in
                    DispatchQueue.main.async {
                        self?.pageImages = images
                    }
                })
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.document.pageCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if let thumbnailCell = cell as? PDFThumbnailCell {
            thumbnailCell.imageView?.image = pageImages?[indexPath.row]
        }
        
        if let activeBorderColor = uiProperties?.activeThumbnailBorderColor,
            let inactiveBorderColor = uiProperties?.inactiveThumbnailBorderColor { // if border colors are available, apply them
            let borderColor = currentPageIndex == indexPath.row ? activeBorderColor : inactiveBorderColor
            cell.layer.borderColor = borderColor.cgColor
            cell.layer.borderWidth = 1.0
        } else { // else change the alpha
            cell.alpha = currentPageIndex == indexPath.row ? 1 : 0.2
        }
        
        return cell
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return PDFThumbnailCell.cellSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectIndexPath(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.bounds.width >= UIScreen.main.bounds.width {
            return UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        }
        return UIEdgeInsets.zero
    }
}

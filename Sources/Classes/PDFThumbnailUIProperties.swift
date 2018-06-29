//
//  PDFThumbnailUIProperties.swift
//  PDFReader
//
//  Created by Vrushali Wani on 29/06/2018.
//  Copyright © 2018 mytrus. All rights reserved.
//

import Foundation

public struct PDFThumbnailUIProperties {
    /// Border color for thumbnail for visible page (active)
    public var activeThumbnailBorderColor: UIColor?
    
    /// Border color for thumbnails for invisible pages (inactive)
    public var inactiveThumbnailBorderColor: UIColor?
    
    /**
     Returns newly initialised PDFThumbnailUIProperties
     
     - activeThumbnailBorderColor: border color for thumbnail for visible page (active)
     - inactiveThumbnailBorderColor: border color for thumbnails for invisible pages (inactive)
     returns: a `PDFThumbnailUIProperties`
     */
    public init(activeThumbnailBorderColor: UIColor?, inactiveThumbnailBorderColor: UIColor?) {
        self.activeThumbnailBorderColor = activeThumbnailBorderColor
        self.inactiveThumbnailBorderColor = inactiveThumbnailBorderColor
    }
}

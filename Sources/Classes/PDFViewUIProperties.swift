//
//  PDFViewUIProperties.swift
//  PDFReader
//
//  Created by Vrushali Wani on 26/06/2018.
//  Copyright © 2018 mytrus. All rights reserved.
//

import Foundation

public struct PDFViewUIProperties {
    /// Title for the pdf
    public var title: String?

    /// font for the title label
    public var titleFont: UIFont?

    /// subtitle for the pdf
    public var subtitle: String?

    /// font for the subtitle label
    public var subtitleFont: UIFont?

    /// image for back button
    public var backButtonImage: UIImage?

    /// Whether or not the thumbnails bar should be enabled
    public var isThumbnailsEnabled: Bool

    /// Color of the line view
    public var lineViewColor: UIColor?

    /// Guid
    public var guid: String

    /// specifies whether the pdf is accessible without subscription. Used for analytics
    public var hasFreeUsagePolicy: Bool

    /**
     Returns newly initialised PDFViewUIProperties
     - guid: Guid of product
     - title: Title for the pdf
     - titleFont: font for the title label
     - subtitle: subtitle for the pdf
     - subtitleFont: font for the subtitle label
     - backButtonImage: image for back button
     - isThumbnailsEnabled: whether or not the thumbnails bar should be enabled
     - lineViewColor: color for the line view
     - hasFreeUsagePolicy: availability to users without subscription
     returns: a `PDFViewUIProperties`
     */
    public init(guid: String, title: String? = nil, titleFont: UIFont? = nil, subtitle: String? = nil, subtitleFont: UIFont? = nil, backButtonImage: UIImage? = nil, isThumbnailsEnabled: Bool = true, lineViewColor: UIColor? = nil, hasFreeUsagePolicy: Bool = false) {
        self.guid = guid
        self.title = title
        self.titleFont = titleFont
        self.subtitle = subtitle
        self.subtitleFont = subtitleFont
        self.backButtonImage = backButtonImage
        self.isThumbnailsEnabled = isThumbnailsEnabled
        self.lineViewColor = lineViewColor
        self.hasFreeUsagePolicy = hasFreeUsagePolicy
    }
}

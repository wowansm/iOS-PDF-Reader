//  PDFViewController.swift
//  PDFReader
//
//  Created by ALUA KINZHEBAYEVA on 4/19/15.
//  Copyright (c) 2015 AK. All rights reserved.
//

import UIKit

extension PDFViewController {
    /// Initializes a new `PDFViewController`
    ///
    /// - parameter document: PDF document to be displayed
    /// - parameter pdfViewProperties: PDFViewUIProperties comprising values and theme for UI components
    /// - parameter thumbnailUIProperties: PDFThumbnailUIProperties comprising theme for UI components
    /// - returns: a `PDFViewController`
    public class func createNew(with document: PDFDocument, pdfViewProperties: PDFViewUIProperties, thumbnailUIProperties: PDFThumbnailUIProperties) -> PDFViewController {
        let storyboard = UIStoryboard(name: "PDFReader", bundle: Bundle(for: PDFViewController.self))
        // swiftlint:disable force_cast
        let controller = storyboard.instantiateInitialViewController() as! PDFViewController
        controller.document = document
        controller.uiProperties = pdfViewProperties
        controller.thumbnailUIProperties = thumbnailUIProperties

        return controller
    }
}

/// Controller that is able to interact and navigate through pages of a `PDFDocument`
public class PDFViewController: UIViewController {
    /// Action button style
    public enum ActionStyle {
        /// Brings up a print modal allowing user to print current PDF
        case print

        /// Brings up an activity sheet to share or open PDF in another app
        case activitySheet

        /// Performs a custom action
        case customAction(() -> Void)
    }

    /// View representing the navigation bar
    @IBOutlet private var navigationView: UIView!

    /// button for returning to previous view
    @IBOutlet private var backButton: UIButton!

    /// Label for title
    @IBOutlet private var titleLabel: UILabel!

    /// Label for subtitle
    @IBOutlet private var subtitleLabel: UILabel!

    /// Line view in the navigation view
    @IBOutlet private var lineView: UIView!

    /// Line view above the thumbnails
    @IBOutlet private var lineViewSeparatingThumbnails: UIView!

    /// Collection veiw where all the pdf pages are rendered
    @IBOutlet private var collectionView: UICollectionView!

    /// Height of the navigation view (used to hide/show)
    @IBOutlet private var navigationViewHeight: NSLayoutConstraint!

    /// Distance between the top of navigation view with top of page (used to hide/show)
    @IBOutlet private var navigationViewTop: NSLayoutConstraint!

    /// Height of the thumbnail bar (used to hide/show)
    @IBOutlet private var thumbnailCollectionControllerHeight: NSLayoutConstraint!

    /// Distance between the bottom thumbnail bar with bottom of page (used to hide/show)
    @IBOutlet private var thumbnailCollectionControllerBottom: NSLayoutConstraint!

    /// Width of the thumbnail bar (used to resize on rotation events)
    @IBOutlet private var thumbnailCollectionControllerWidth: NSLayoutConstraint!

    /// PDF document that should be displayed
    private var document: PDFDocument!

    private var actionStyle: ActionStyle?

    /// Image used to override the default action button image
    private var actionButtonImage: UIImage?

    /// Current page being displayed
    private var currentPageIndex: Int = 0

    /// Bottom thumbnail controller
    private var thumbnailCollectionController: PDFThumbnailCollectionViewController?

    /// UIBarButtonItem used to override the default action button
    private var actionButton: UIBarButtonItem?

    /// Background color to apply to the collectionView.
    public var backgroundColor: UIColor? = .lightGray

    /// Whether or not the thumbnails bar should be enabled
    private var isThumbnailsEnabled = true {
        didSet {
            if thumbnailCollectionControllerHeight == nil {
                _ = view
            }
            if !isThumbnailsEnabled {
                thumbnailCollectionControllerHeight.constant = 0
            }
        }
    }

    /// Slides horizontally (from left to right, default) or vertically (from top to bottom)
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet {
            if collectionView == nil { // if the user of the controller is trying to change the scrollDiecton before it
                _ = view // is on the sceen, we need to show it ofscreen to access it's collectionView.
            }
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = scrollDirection
            }
        }
    }

    /// UI values
    public var uiProperties: PDFViewUIProperties?

    ///Thumbnail UI properties
    private var thumbnailUIProperties: PDFThumbnailUIProperties?

    /// Reset page when its unpresented
    public var resetZoom: Bool = false

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColor
        collectionView.backgroundColor = backgroundColor
        collectionView.register(PDFPageCollectionViewCell.self, forCellWithReuseIdentifier: "page")

//        navigationItem.rightBarButtonItem = actionButton

        navigationItem.hidesBackButton = true

        let numberOfPages = CGFloat(document.pageCount)
        let cellSpacing = CGFloat(2.0)
        let totalSpacing = (numberOfPages - 1.0) * cellSpacing
        let thumbnailWidth = (numberOfPages * PDFThumbnailCell.cellSize.width) + totalSpacing
        let width = min(thumbnailWidth, view.bounds.width)
        thumbnailCollectionControllerWidth.constant = width

        if let properties = uiProperties {
            if let title = properties.title {
                titleLabel.text = title
                if let font = properties.titleFont {
                    titleLabel.font = font
                }
            } else {
                titleLabel.text = ""
            }
            if let subtitle = properties.subtitle {
                subtitleLabel.text = subtitle
                if let font = properties.subtitleFont {
                    subtitleLabel.font = font
                }
            } else {
                subtitleLabel.text = ""
            }

            backButton.setImage(properties.backButtonImage, for: .normal)
            backButton.setTitle((properties.backButtonImage != nil ? "" : "Back"), for: .normal)

            isThumbnailsEnabled = properties.isThumbnailsEnabled

            if let lineViewColor = properties.lineViewColor {
                lineView.backgroundColor = lineViewColor
                lineViewSeparatingThumbnails.backgroundColor = lineViewColor
            }
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        navigationController?.popViewController(animated: true)
    }

    override public var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }

    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return isThumbnailsEnabled
    }

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PDFThumbnailCollectionViewController {
            thumbnailCollectionController = controller
            controller.document = document
            controller.uiProperties = thumbnailUIProperties
            controller.delegate = self
            controller.currentPageIndex = currentPageIndex
        }
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            let currentIndexPath = IndexPath(row: self.currentPageIndex, section: 0)
            self.collectionView.reloadItems(at: [currentIndexPath])
            self.collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
        }) { _ in
            self.thumbnailCollectionController?.currentPageIndex = self.currentPageIndex
        }

        super.viewWillTransition(to: size, with: coordinator)
    }

    ///Back button tapped
    @IBAction private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    /// Takes an appropriate action based on the current action style
    @objc
    func actionButtonPressed() {
        if let actionStyle = actionStyle {
            switch actionStyle {
            case .print:
                print()
            case .activitySheet:
                presentActivitySheet()
            case .customAction(let customAction):
                customAction()
            }
        }
    }

    /// Presents activity sheet to share or open PDF in another app
    private func presentActivitySheet() {
        let controller = UIActivityViewController(activityItems: [document.fileData], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = actionButton
        present(controller, animated: true, completion: nil)
    }

    /// Presents print sheet to print PDF
    private func print() {
        guard UIPrintInteractionController.isPrintingAvailable else { return }
        guard UIPrintInteractionController.canPrint(document.fileData) else { return }
        guard document.password == nil else { return }
        let printInfo = UIPrintInfo.printInfo()
        printInfo.duplex = .longEdge
        printInfo.outputType = .general
        printInfo.jobName = document.fileName

        let printInteraction = UIPrintInteractionController.shared
        printInteraction.printInfo = printInfo
        printInteraction.printingItem = document.fileData
        printInteraction.present(animated: true, completionHandler: nil)
    }
}

extension PDFViewController: PDFThumbnailControllerDelegate {
    func didSelectIndexPath(_ indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        thumbnailCollectionController?.currentPageIndex = currentPageIndex
    }
}

extension PDFViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return document.pageCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath)
        if let pageCell = cell as? PDFPageCollectionViewCell {
            pageCell.setup(indexPath.row, collectionViewBounds: collectionView.bounds, document: document, pageCollectionViewCellDelegate: self)
        }
        return cell
    }
}

extension PDFViewController: PDFPageCollectionViewCellDelegate {

    func handleSingleTap(_ cell: PDFPageCollectionViewCell, pdfPageView: PDFPageView) {
        if navigationViewTop.constant < CGFloat(0.0) {
            navigationViewTop.constant = CGFloat(0.0)
            thumbnailCollectionControllerBottom.constant = CGFloat(0.0)
        } else {
            navigationViewTop.constant = -navigationViewHeight.constant
            thumbnailCollectionControllerBottom.constant = -thumbnailCollectionControllerHeight.constant
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

extension PDFViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

extension PDFViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let updatedPageIndex: Int
        if self.scrollDirection == .vertical {
            updatedPageIndex = Int(round(max(scrollView.contentOffset.y, 0) / scrollView.bounds.height))
        } else {
            updatedPageIndex = Int(round(max(scrollView.contentOffset.x, 0) / scrollView.bounds.width))
        }

        if updatedPageIndex != currentPageIndex {
            if resetZoom {
                self.collectionView.reloadItems(at: [IndexPath(item: currentPageIndex, section: 0)])
            }
            currentPageIndex = updatedPageIndex
            thumbnailCollectionController?.currentPageIndex = currentPageIndex
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if navigationViewTop.constant != -navigationViewHeight.constant {
            navigationViewTop.constant = -navigationViewHeight.constant
            thumbnailCollectionControllerBottom.constant = -thumbnailCollectionControllerHeight.constant
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

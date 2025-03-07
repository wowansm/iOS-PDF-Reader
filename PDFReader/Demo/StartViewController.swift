//
//  StartViewController.swift
//  PDFReader
//
//  Created by Ricardo Nunez on 7/8/16.
//  Copyright © 2016 AK. All rights reserved.
//

import UIKit
import PDFReader

/// Presents user with some documents which can be viewed
internal final class StartViewController: UIViewController {
    /// Displays a smaller sized PDF document
    @IBAction private func showSmallPDFDocument() {
        let smallPDFDocumentName = "apple"
        if let doc = document(smallPDFDocumentName) {
            showDocument(doc)
        } else {
            print("Document named \(smallPDFDocumentName) not found in the file system")
        }
    }

    /// Displays a larger sized PDF document
    @IBAction private func showRemotePDFDocument() {
        let remotePDFDocumentURLPath = "http://devstreaming.apple.com/videos/wwdc/2016/201h1g4asm31ti2l9n1/201/201_internationalization_best_practices.pdf"
        if let remotePDFDocumentURL = URL(string: remotePDFDocumentURLPath), let doc = document(remotePDFDocumentURL) {
            showDocument(doc)
        } else {
            print("Document named \(remotePDFDocumentURLPath) not found")
        }
    }

    /// Displays an insanely large sized PDF document
    @IBAction private func showInsanelyLargePDFDocument() {
        let insanelyLargePDFDocumentName = "javaScript"
        if let doc = document(insanelyLargePDFDocumentName) {
            showDocument(doc)
        } else {
            print("Document named \(insanelyLargePDFDocumentName) not found in the file system")
        }
    }

    /// Initializes a document with the name of the pdf in the file system
    private func document(_ name: String) -> PDFDocument? {
        guard let documentURL = Bundle.main.url(forResource: name, withExtension: "pdf") else { return nil }
        return PDFDocument(url: documentURL)
    }

    /// Initializes a document with the data of the pdf
    private func document(_ data: Data) -> PDFDocument? {
        return PDFDocument(fileData: data, fileName: "Sample PDF")
    }

    /// Initializes a document with the remote url of the pdf
    private func document(_ remoteURL: URL) -> PDFDocument? {
        return PDFDocument(url: remoteURL)
    }

    /// Presents a document
    ///
    /// - parameter document: document to present
    ///
    private func showDocument(_ document: PDFDocument) {
        let pdfViewProperties = PDFViewUIProperties(guid: "123", title: "PDF", titleFont: UIFont(name: "Verdana", size: 16.0), subtitle: "subtitle", subtitleFont: UIFont(name: "Veradana", size: 13.0), backButtonImage: UIImage(named: "buttonBack64"), isThumbnailsEnabled: true, lineViewColor: .red)
        let thumbnailUIProperties = PDFThumbnailUIProperties(activeThumbnailBorderColor: .black, inactiveThumbnailBorderColor: .lightGray)
        let controller = PDFViewController.createNew(with: document, pdfViewProperties: pdfViewProperties, thumbnailUIProperties: thumbnailUIProperties)
        controller.backgroundColor = UIColor(red: 133 / 255, green: 132 / 255, blue: 138 / 255, alpha: 1.0)
        navigationController?.pushViewController(controller, animated: true)
    }
}

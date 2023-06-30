//
//  UICollectionView+Extensions.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 17/03/23.
//

import UIKit

extension UICollectionView {

    func setMensajeVacio(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .systemBlue
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        backgroundView = messageLabel;
    }

    func restore() {
        backgroundView = nil
    }
}

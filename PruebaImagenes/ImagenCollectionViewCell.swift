//
//  ImagenCollectionViewCell.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 21/10/22.
//

import UIKit

class ImagenCollectionViewCell: UICollectionViewCell {
    static let id = "ImagenCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect){
        super.init(frame:frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with urlString: String){
        ImageClient.mostrarImagen(imageURL: urlString, imageView: imageView, completionHandler: {_ in})
    }
    
    func configure(with data: NSData){
        imageView.image = UIImage(data: data as Data)?.resized(withPercentage: 0.1)
    }
}

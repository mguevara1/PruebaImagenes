//
//  ImagenTableViewCell.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 3/07/22.
//

import UIKit

class ImagenTableViewCell: UITableViewCell {
    @IBOutlet weak var profilepictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var imagenImageView: UIImageView!
    
    static let identifier = "ImagenTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ImagenTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func mostrarImagen(imageURL: String, imageView: UIImageView){
        guard let url = URL(string: imageURL) else{
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
    
    func configure(with structImg: StructImagen){
        self.likesLabel.text = "\(structImg.numberOfLikes) Likes"
        self.usernameLabel.text = structImg.username
        //self.profilepictureImageView.image = UIImage(named: structImg.userImageName)
        //self.imagenImageView.image = UIImage(named: structImg.imageImageName)
        mostrarImagen(imageURL: structImg.userImageURL, imageView: self.profilepictureImageView)
        mostrarImagen(imageURL: structImg.imageImageURL, imageView: self.imagenImageView)
    }
    
}

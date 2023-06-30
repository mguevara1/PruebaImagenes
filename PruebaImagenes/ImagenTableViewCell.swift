//
//  ImagenTableViewCell.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 3/07/22.
//

import UIKit
import CoreData

class ImagenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilepictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var imagenImageView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var favoritos: [NSManagedObject] = []
    
    var imgId: String = " "
    var name: String = " "
    var location: String = " "
    var total_photos: Int = 0
    var likes: Int = 0
    
    static let identifier = "ImagenTableViewCell"
    
    
    static func nib() -> UINib {
        return UINib(nibName: "ImagenTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityIndicator.hidesWhenStopped = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
    func configure(with structImg: StructImagen) {
        print("configure \(structImg.id)")
        likesLabel.text = "\(structImg.numberOfLikes) Likes"
        usernameLabel.text = structImg.username
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        ImageClient.mostrarImagen(imageURL: structImg.userImageURL, imageView: profilepictureImageView, completionHandler: {_ in })
        imgId = structImg.id
        activityIndicator.stopAnimating()
        total_photos = structImg.total_photos ?? 0
        name = structImg.name ?? "N/A"
        location = structImg.location ?? "Unknown"
        likes = structImg.numberOfLikes
    }
    
    func guardar() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Favorito", in: managedContext)!
        let favorito = NSManagedObject(entity: entity, insertInto: managedContext)
        favorito.setValue(usernameLabel.text, forKeyPath: "username")
        favorito.setValue(imgId, forKeyPath: "id")
        let imgData: NSData = imagenImageView.image!.pngData()! as NSData
        favorito.setValue(imgData, forKeyPath: "image")
        favorito.setValue(name, forKeyPath: "name")
        favorito.setValue(location, forKeyPath: "location")
        favorito.setValue(likes, forKeyPath: "likes")
        favorito.setValue(total_photos, forKeyPath: "total_photos")
        do {
            try managedContext.save()
            self.favoritos.append(favorito)
            print("Guardado")
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        } catch let error as NSError {
            print("No se pudo guardar. \(error), \(error.userInfo)")
        }
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    
    @IBAction func favAction(_ sender: Any) {
        print("Guardando...")
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        guardar()
        favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
    }
    
    
    @IBAction func verUsuario(_ sender: Any) {
    }
    
}



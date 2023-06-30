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
    
    var activityIndicator = UIActivityIndicatorView(style: .large)
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
        // Initialization code
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
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
        mostrarImagen(imageURL: structImg.userImageURL, imageView: self.profilepictureImageView)
        mostrarImagen(imageURL: structImg.imageImageURL, imageView: self.imagenImageView)
        self.activityIndicator.stopAnimating()
        self.imgId = structImg.id
        self.total_photos = structImg.total_photos ?? 0
        self.name = structImg.name ?? ""
        self.location = structImg.location ?? ""
        self.likes = structImg.numberOfLikes
    }
    
    func guardar() {
        
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

      let managedContext = appDelegate.persistentContainer.viewContext
      let entity = NSEntityDescription.entity(forEntityName: "Favorito", in: managedContext)!
      let favorito = NSManagedObject(entity: entity, insertInto: managedContext)
        favorito.setValue(self.usernameLabel.text, forKeyPath: "username")
        favorito.setValue(self.imgId, forKeyPath: "id")
        let imgData: NSData = self.imagenImageView.image!.pngData()! as NSData
        favorito.setValue(imgData, forKeyPath: "image")
        favorito.setValue(self.name, forKeyPath: "name")
        favorito.setValue(self.location, forKeyPath: "location")
        favorito.setValue(self.likes, forKeyPath: "likes")
        favorito.setValue(self.total_photos, forKeyPath: "total_photos")
      do {
        try managedContext.save()
          self.favoritos.append(favorito)
          print("Guardado")
      } catch let error as NSError {
        print("No se pudo guardar. \(error), \(error.userInfo)")
      }
    }
    
    
    @IBAction func favAction(_ sender: Any) {
        print("Guardando...")
        activityIndicator.startAnimating()
        guardar()
        favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        self.activityIndicator.stopAnimating()

    }
    
    
    @IBAction func verUsuario(_ sender: Any) {
    }
    
}



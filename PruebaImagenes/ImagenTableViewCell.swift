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
    
    var favoritos: [NSManagedObject] = []
    
    var imgId: String = ""
    
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
        self.imgId = structImg.id
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
        print(imgData)
        favorito.setValue(imgData, forKeyPath: "image")
      do {
        try managedContext.save()
          self.favoritos.append(favorito)
          print("Guardado")
      } catch let error as NSError {
        print("No se pudo guardar. \(error), \(error.userInfo)")
      }
    }
    
    
    @IBAction func more(_ sender: Any) {
        guardar()
    }
    
}

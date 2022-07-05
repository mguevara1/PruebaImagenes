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
        //print(imgData)
        favorito.setValue(imgData, forKeyPath: "image")
      do {
        try managedContext.save()
          self.favoritos.append(favorito)
          print("Guardado")
      } catch let error as NSError {
        print("No se pudo guardar. \(error), \(error.userInfo)")
      }
    }
    
    
    @IBAction func favAction(_ sender: Any) {
        guardar()
        favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        //Toast.show(message: "My message", controller: self.tableView.delegate)
    }
    
}

class Toast {
    static func show(message: String, controller: UIViewController) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 25;
        toastContainer.clipsToBounds  =  true

        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0

        toastContainer.addSubview(toastLabel)
        controller.view.addSubview(toastContainer)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false

        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
        toastContainer.addConstraints([a1, a2, a3, a4])

        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -75)
        controller.view.addConstraints([c1, c2, c3])

        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}

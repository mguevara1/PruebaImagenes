//
//  DetallesTableViewController.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 4/07/22.
//

import UIKit
import CoreData

class DetallesTableViewController: UITableViewController {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var imagenCell: UITableViewCell!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalphotosLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var favoritos: [NSManagedObject] = []
    var isFavoritesView: Bool = false 
    var isSaved: Bool = false
    
    var id:String = ""
    var username:String = ""
    var img: UIImage?
    var name:String = ""
    var location:String = ""
    var total_photos:String = "0"
    var likes: String = "0"
    var userimage: String?
    
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        actionButton.image = isFavoritesView ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        
        idLabel.text = id
        userLabel.text = username
        nameLabel.text = name
        locationLabel.text = location
        totalphotosLabel.text = total_photos
        likesLabel.text = likes
        
        if let img = img {
            imagenCell.imageView?.image = img
        }
        
        if existeFavorito(id: id) {
            isSaved = true
            actionButton.image = UIImage(systemName: "heart.fill")
        }
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
    }
    
    func deleteFavorito(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let viewContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorito")
        let predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.predicate = predicate
            let result = try? viewContext.fetch(fetchRequest)
            let resultData = result as! [Favorito]

            for object in resultData {
                viewContext.delete(object)
            }

            do {
                try viewContext.save()
                actionButton.image = UIImage(systemName: "heart")
                print("Eliminado!")
                showInfoMessage("Removed from favorites")
            } catch let error as NSError  {
                print("No se pudo eliminar: \(error), \(error.userInfo)")
                showAlert(message: "Error deleting: \(error)", title: "Error")
            }
    }
    
    func configure(with urlString: String){
        ImageClient.mostrarImagen(imageURL: urlString, imageView: imagenCell.imageView!, completionHandler: {_ in})
    }
    
    @IBAction func didTapAction(_ sender: Any) {
        isSaved ? didTapRemove() : didTapSave()
    }

    func existeFavorito(id: String) -> Bool {
        
        var results: [NSManagedObject] = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favorito")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            results = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error al leer base de datos de favoritos. \(error), \(error.userInfo)")
            showAlert(message: error.localizedDescription, title: "Error")
        }
        
        return !results.isEmpty
    }
    
    func saveFavorito() {
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Favorito", in: managedContext)!
        let favorito = NSManagedObject(entity: entity, insertInto: managedContext)
        favorito.setValue(username, forKeyPath: "username")
        favorito.setValue(id, forKeyPath: "id")
        let imgData: NSData = img!.pngData()! as NSData
        favorito.setValue(imgData, forKeyPath: "image")
        favorito.setValue(name, forKeyPath: "name")
        favorito.setValue(location, forKeyPath: "location")
        favorito.setValue(Int(likes), forKeyPath: "likes")
        favorito.setValue(Int(total_photos), forKeyPath: "total_photos")
        do {
            try managedContext.save()
            self.favoritos.append(favorito)
            print("Guardado")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.showInfoMessage("Image saved in favorites")
            }
        } catch let error as NSError {
            print("No se pudo guardar. \(error), \(error.userInfo)")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.showAlert(message: "Error Saving. \(error.localizedDescription)", title: "Error")
            }
        }
    }
    
    func didTapSave() {
        if isSaved {
            showAlert(message: "Image already saved", title: "Info")
        } else {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.persistentStoreCoordinator = managedContext.persistentStoreCoordinator
            privateContext.perform {
                
                DispatchQueue.main.async {
                    print("Guardando...")
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                }
                self.saveFavorito()
            }
            
        }
    }
    
    func showInfoMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true)
        
        let duration: Double = 1.5
            
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func didTapRemove() {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Do you want to remove from favorites?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("ok tapped")
            self.deleteFavorito()
            _ = self.navigationController?.popViewController(animated: true)
            
        })
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
            print("Cancel tapped")
            
        }
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func showAlert(message: String, title: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
}

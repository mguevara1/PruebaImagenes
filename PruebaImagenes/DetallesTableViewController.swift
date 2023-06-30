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
    
    
    var id:String?
    var username:String?
    var img: UIImage?
    var name:String?
    var location:String?
    var total_photos:String?
    var likes: String?
    var userimage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((id) != nil) {
            idLabel.text = id
        }
        
        if ((username) != nil){
            userLabel.text = username
        }
        if ((img) != nil){
            imagenCell.imageView?.image = img 
        }
        if ((name) != nil){
            nameLabel.text = name
        }else{
            nameLabel.text = ""
        }
        if ((location) != nil){
            locationLabel.text = location
        }else{
            locationLabel.text = ""
        }
        if ((total_photos) != nil){
            totalphotosLabel.text = total_photos
        }else{
            totalphotosLabel.text = "0"
        }
        if ((likes) != nil){
            likesLabel.text = likes
        }else{
            likesLabel.text = "0"
        }
        if(userimage != nil){
            configure(with: userimage!)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func deleteFavorito(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let viewContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorito")
        let predicate = NSPredicate(format: "id == %@", self.id!)
            fetchRequest.predicate = predicate
            let result = try? viewContext.fetch(fetchRequest)
            let resultData = result as! [Favorito]

            for object in resultData {
                viewContext.delete(object)
                print("Eliminado!")
            }

            do {
                try viewContext.save()
            } catch let error as NSError  {
                print("No se pudo eliminar: \(error), \(error.userInfo)")
            }
    }
    
    func configure(with urlString: String){
        guard let url = URL(string: urlString) else{
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self?.imagenCell.imageView?.image = image
            }
        }.resume()
    }
    
    @IBAction func remove(_ sender: Any) {
        let dialogMessage = UIAlertController(title: "Confirmar", message: "Desea remover de favoritos?", preferredStyle: .alert)
        
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

}

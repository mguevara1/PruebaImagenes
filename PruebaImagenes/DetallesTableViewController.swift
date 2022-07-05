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
    
    var id:String?
    var username:String?
    var img: UIImage?
    
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
    
    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = "a"

        return cell
    }*/
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

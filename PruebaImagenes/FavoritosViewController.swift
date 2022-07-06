//
//  FavoritosViewController.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 4/07/22.
//

import UIKit
import CoreData

class FavoritosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    private var collectionView: UICollectionView?
    var favoritos: [NSManagedObject] = []
    var selectedIndex: Int = 0
    
    let barrabusqueda = UISearchBar()
    var activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        //self.showSpinner(onView: self.view)
        super.viewDidLoad()
        
        barrabusqueda.delegate = self
        view.addSubview(barrabusqueda)
        //barrabusqueda.showsCancelButton = true
        barrabusqueda.searchTextField.placeholder = "usuario"
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImagenCollectionViewCell.self, forCellWithReuseIdentifier: ImagenCollectionViewCell.id)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true 
        view.addSubview(collectionView)
        self.collectionView = collectionView
        //obtenerFavoritos()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barrabusqueda.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        //collectionView?.frame = view.bounds
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+50, width: view.frame.size.width, height: view.frame.size.height-50)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        favoritos.removeAll()
        //obtenerFavoritos(busqueda: "modcatshop")
        obtenerFavoritos()
        self.activityIndicator.stopAnimating()
    }
    
    func obtenerFavoritos(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favorito")

        do {
          favoritos = try managedContext.fetch(fetchRequest)
            self.collectionView?.reloadData()
        } catch let error as NSError {
          print("Error al leer base de datos de favoritos. \(error), \(error.userInfo)")
        }
        //print(favoritos.count)
    }
    
    func obtenerFavoritos(busqueda: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favorito")
        fetchRequest.predicate = NSPredicate(format: "username contains[c] %@", busqueda)
        do {
          favoritos = try managedContext.fetch(fetchRequest)
            //self.collectionView?.reloadData()
        } catch let error as NSError {
          print("Error al leer base de datos de favoritos. \(error), \(error.userInfo)")
        }
        //print(favoritos.count)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        barrabusqueda.resignFirstResponder()
        if let texto = barrabusqueda.text {
            obtenerFavoritos(busqueda: texto)
            collectionView?.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        activityIndicator.startAnimating()
        obtenerFavoritos()
        collectionView?.reloadData()
        self.activityIndicator.stopAnimating()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.favoritos.count == 0) {
            self.collectionView?.setMensajeVacio("Aún no tienes imágenes favoritas 😎")
           } else {
               self.collectionView?.restore()
           }
        
        return favoritos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataImg = favoritos[indexPath.row].value(forKey: "image") as! NSData
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagenCollectionViewCell.id, for: indexPath) as? ImagenCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.configure(with: dataImg)
        return cell
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?){
        let detallesTVC = segue.destination as! DetallesTableViewController
        detallesTVC.id = favoritos[selectedIndex].value(forKey: "id") as? String
        detallesTVC.username = favoritos[selectedIndex].value(forKey: "username") as? String
        detallesTVC.name = favoritos[selectedIndex].value(forKey: "name") as? String
        detallesTVC.likes = favoritos[selectedIndex].value(forKey: "likes") as? String
        detallesTVC.location = favoritos[selectedIndex].value(forKey: "location") as? String
        detallesTVC.total_photos = favoritos[selectedIndex].value(forKey: "total_photos") as? String
        let dataimg = favoritos[selectedIndex].value(forKey: "image") as! NSData
        let imgV: UIImage = UIImage(data: dataimg  as Data)!
        detallesTVC.img = imgV 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "DetallesSegue", sender: self)
    }
    
}
extension UICollectionView {

    func setMensajeVacio(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .systemBlue
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}


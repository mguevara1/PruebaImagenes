//
//  FavoritosViewController.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 4/07/22.
//

import UIKit
import CoreData

class FavoritosViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    private var collectionView: UICollectionView?
    var favoritos: [NSManagedObject] = []
    var selectedIndex: Int = 0
    
    let barrabusqueda = UISearchBar()
    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barrabusqueda.delegate = self
        view.addSubview(barrabusqueda)
        barrabusqueda.searchTextField.placeholder = "search user"
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/4, height: view.frame.size.width/4)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImagenCollectionViewCell.self, forCellWithReuseIdentifier: ImagenCollectionViewCell.id)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        view.addSubview(collectionView)
        self.collectionView = collectionView
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barrabusqueda.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+50, width: view.frame.size.width, height: view.frame.size.height-50)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        favoritos.removeAll()
        obtenerFavoritos()
        activityIndicator.stopAnimating()
    }
    
    func obtenerFavoritos(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favorito")
        
        do {
            favoritos = try managedContext.fetch(fetchRequest)
            collectionView?.reloadData()
        } catch let error as NSError {
            debugPrint("Error al leer base de datos de favoritos. \(error), \(error.userInfo)")
            showAlert(message: error.localizedDescription, title: "Error")
        }
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
        } catch let error as NSError {
            print("Error al leer base de datos de favoritos. \(error), \(error.userInfo)")
            showAlert(message: error.localizedDescription, title: "Error")
        }
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
        activityIndicator.stopAnimating()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.favoritos.count == 0) {
            self.collectionView?.setMensajeVacio("Your favorites will appear here 😎")
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
        detallesTVC.id = favoritos[selectedIndex].value(forKey: "id") as! String
        detallesTVC.username = favoritos[selectedIndex].value(forKey: "username") as? String ?? ""
        detallesTVC.name = favoritos[selectedIndex].value(forKey: "name") as? String ?? "N/A"
        detallesTVC.likes = favoritos[selectedIndex].value(forKey: "likes") as? String ?? "0"
        detallesTVC.location = favoritos[selectedIndex].value(forKey: "location") as? String ?? "Unknown"
        detallesTVC.total_photos = favoritos[selectedIndex].value(forKey: "total_photos") as? String ?? "0"
        let dataimg = favoritos[selectedIndex].value(forKey: "image") as! NSData
        let img: UIImage = UIImage(data: dataimg  as Data)!
        detallesTVC.img = img
        detallesTVC.isFavoritesView = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "DetallesSegue", sender: self)
    }
    
}

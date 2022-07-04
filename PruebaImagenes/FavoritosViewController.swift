//
//  FavoritosViewController.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 4/07/22.
//

import UIKit
import CoreData

class FavoritosViewController: UIViewController, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView?
    var favoritos: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImagenCollectionViewCell.self, forCellWithReuseIdentifier: ImagenCollectionViewCell.id)
        collectionView.dataSource = self
        view.addSubview(collectionView)
        self.collectionView = collectionView
        obtenerFavoritos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //barrabusqueda.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        //collectionView?.frame = view.bounds
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+50, width: view.frame.size.width, height: view.frame.size.height-50)
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
        print(favoritos.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
}

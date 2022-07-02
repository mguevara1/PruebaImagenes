//
//  ViewController.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 1/07/22.
//

import UIKit
//import XCTest

struct RespuestaAPI: Codable{
    let total: Int
    let total_pages: Int
    let results: [Resultado]
}

struct Resultado: Codable {
    let id: String
    let urls: URLS
}

struct URLS: Codable {
    let full: String
}

class ImagenesViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {
    
    //let urlBusquedaImagenes = "https://api.unsplash.com/search/photos?page=1&per_page=10&query=cats&client_id=JyY5KVg1qB9PR2vt3reK2FmOZzng80sZsOkPMik9cTE"
    
    private var collectionView: UICollectionView?
    
    var results: [Resultado] = []
    
    let barrabusqueda = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        barrabusqueda.delegate = self
        view.addSubview(barrabusqueda)
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
        obtenerImagenes(busqueda: "cats")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barrabusqueda.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        //collectionView?.frame = view.bounds
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+50, width: view.frame.size.width, height: view.frame.size.height-50)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        barrabusqueda.resignFirstResponder()
        if let texto = barrabusqueda.text {
            results = []
            collectionView?.reloadData()
            obtenerImagenes(busqueda: texto)
        }
    }
    
    func obtenerImagenes(busqueda: String){
        let urlBusquedaImagenes = "https://api.unsplash.com/search/photos?page=1&per_page=10&query=\(busqueda)&client_id=JyY5KVg1qB9PR2vt3reK2FmOZzng80sZsOkPMik9cTE"
        guard let url = URL(string: urlBusquedaImagenes) else{
            return
        }
        let tarea = URLSession.shared.dataTask(with: url){data, _, error in
            guard let data = data, error == nil else{
                return
            }
            do {
                let resultado = try JSONDecoder().decode(RespuestaAPI.self, from: data)
                DispatchQueue.main.async{
                    self.results = resultado.results
                    self.collectionView?.reloadData()
                }
                print(resultado.results.count)
            }
            catch {
                print(error)
            }
        }
        tarea.resume()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let URLimg = results[indexPath.row].urls.full
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagenCollectionViewCell.id, for: indexPath) as? ImagenCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.configure(with: URLimg)
        return cell
    }
}


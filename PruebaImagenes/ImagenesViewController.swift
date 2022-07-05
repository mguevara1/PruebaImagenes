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
    let likes: Int
    let user: USER
}

struct URLS: Codable {
    let full: String
}

struct USER: Codable {
    let username: String
    let profile_image: PROFILE_IMAGE
}

struct PROFILE_IMAGE: Codable {
    let medium: String
}

class ImagenesViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    var structImgs = [StructImagen]()
    var currentPage: Int = 0
    var searchText: String?
   
    //let urlBusquedaImagenes = "https://api.unsplash.com/search/photos?page=1&per_page=10&query=cats&client_id=JyY5KVg1qB9PR2vt3reK2FmOZzng80sZsOkPMik9cTE"
    
    private var collectionView: UICollectionView?
    
    var results: [Resultado] = []
    
    let barrabusqueda = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        barrabusqueda.delegate = self
        view.addSubview(barrabusqueda)

        table.register(ImagenTableViewCell.nib(), forCellReuseIdentifier: ImagenTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        
        self.currentPage = 1
        self.searchText = "cats"
        obtenerImagenes(busqueda: self.searchText!)
        print("Paginas: \(self.currentPage)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barrabusqueda.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        //collectionView?.frame = view.bounds
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+50, width: view.frame.size.width, height: view.frame.size.height-50)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = structImgs.count - 1
            if indexPath.row == lastElement {
               //print("end")
                self.currentPage += 1
                print("Paginas: \(self.currentPage)")
                obtenerImagenes(busqueda: self.searchText!)
                //print("Imagenes: \(structImgs.count)")
            }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        barrabusqueda.resignFirstResponder()
        if let texto = barrabusqueda.text {
            //results = []
            self.searchText = texto
            results.removeAll()
            structImgs.removeAll()
            //collectionView?.reloadData()
            table?.reloadData()
            currentPage = 1
            obtenerImagenes(busqueda: texto)
            table?.reloadData()
        }
    }
    
    func obtenerImagenes(busqueda: String){
        let urlBusquedaImagenes = "https://api.unsplash.com/search/photos?page=\(currentPage)&per_page=10&query=\(busqueda)&client_id=JyY5KVg1qB9PR2vt3reK2FmOZzng80sZsOkPMik9cTE"
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
                    //self.collectionView?.reloadData()
                    self.table?.reloadData()
                }
                //print(resultado.results.count)
                for r in resultado.results{
                    self.structImgs.append(StructImagen(numberOfLikes: r.likes, username: r.user.username, userImageURL: r.user.profile_image.medium, imageImageURL: r.urls.full, id: r.id))
                }
                print("Total Imagenes: \(self.structImgs.count)")
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
        //print(results[indexPath.row].user.username)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagenCollectionViewCell.id, for: indexPath) as? ImagenCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.configure(with: URLimg)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structImgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagenTableViewCell.identifier, for: indexPath) as! ImagenTableViewCell
        
        cell.configure(with: structImgs[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 335
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

struct StructImagen{
    let numberOfLikes: Int
    let username: String
    let userImageURL: String
    let imageImageURL: String
    let id: String
}

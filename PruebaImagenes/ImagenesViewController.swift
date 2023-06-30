//
//  ViewController.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 1/07/22.
//

import UIKit

class ImagenesViewController: BaseViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    var structImgs = [StructImagen]()
    var arrayImgs: [Result] = []
    var currentPage: Int = 0
    var searchText: String?
    var userIndexTag: Int = 0
    var userImage: UIImage?
    
    private var collectionView: UICollectionView?
    
    public static var cachedImages: [String : UIImage] = [:]
    
    let barrabusqueda = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        barrabusqueda.delegate = self
        view.addSubview(barrabusqueda)
        barrabusqueda.searchTextField.placeholder = "Search images..."
        table.delegate = self
        table.dataSource = self
        self.currentPage = 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barrabusqueda.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+50, width: view.frame.size.width, height: view.frame.size.height-50)
    }
    
    func getImages() {

        ImageClient.obtenerImagenes(busqueda: self.searchText!, currentPage: currentPage, completion: { (result, error) in
            
            if let result = result {
                self.arrayImgs = result
                for r in result{
                    ImageClient.getImage(imageId: r.id, imageURL: r.urls.full, completionHandler: {id, image, error in
                        DispatchQueue.main.async {
                            self.hideActivityIndicator()
                        }
                        
                        if let id = id, let image = image {
                            ImagenesViewController.cachedImages[id] = image
                            self.structImgs.append(StructImagen(numberOfLikes: r.likes, username: r.user.username, name: r.user.name, location: r.user.location, total_photos: r.user.total_photos, userImageURL: r.user.profile_image.medium, imageImageURL: r.urls.full, image: image, id: r.id))
                            self.table.reloadData()
                        } else {
                            if let error = error {
                                print(error.localizedDescription)
                                DispatchQueue.main.async {
                                    self.showAlert(message: error.localizedDescription, title: "Error")
                                }
                            }
                        }
                    })
                }
            } else {
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.showAlert(message: error?.localizedDescription ?? "Error fetching images", title: "Error")
                }
            }
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        barrabusqueda.resignFirstResponder()
        if let texto = barrabusqueda.text {
            self.searchText = texto
            structImgs.removeAll()
            ImagenesViewController.cachedImages.removeAll()
            table?.reloadData()
            currentPage = 1
            showActivityIndicator()
            getImages()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImagenesViewController.cachedImages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewCell", for: indexPath)
        cell.imageView?.center = cell.center
        let cellImg : UIImageView = UIImageView(frame: CGRectMake(0, 0, 150, 150))
        cellImg.image = structImgs[indexPath.row].image.resized(withPercentage: 0.1)
        cell.addSubview(cellImg)
        
        return cell
    }
    
    @objc func buttonTapped(_ sender:UIButton!){
        print(sender.tag)
        self.userIndexTag = sender.tag
        self.performSegue(withIdentifier: "userSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "userSegue") {
            if let detallesTVC = segue.destination as? DetallesTableViewController {
                let id = structImgs[userIndexTag].id
                detallesTVC.id = id
                detallesTVC.username = structImgs[userIndexTag].username
                detallesTVC.name = structImgs[userIndexTag].name ?? "N/A"
                detallesTVC.likes = String(structImgs[userIndexTag].numberOfLikes)
                detallesTVC.location = structImgs[userIndexTag].location ?? "Unknown"
                detallesTVC.total_photos = String(structImgs[userIndexTag].total_photos ?? 0)
                let dataimg = ImagenesViewController.cachedImages[id]
                detallesTVC.img = dataimg
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userIndexTag = indexPath.row
        performSegue(withIdentifier: "userSegue", sender: self)
    }
}

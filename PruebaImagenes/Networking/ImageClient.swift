//
//  ImageClient.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 13/03/23.
//
import UIKit
import Foundation

class ImageClient {
    
    class func obtenerImagenes(busqueda: String, currentPage: Int, completion: @escaping ([Result]?, Error?) -> Void){
        
        let urlBusquedaImagenes = "https://api.unsplash.com/search/photos?page=\(currentPage)&per_page=10&query=\(busqueda)&client_id=JyY5KVg1qB9PR2vt3reK2FmOZzng80sZsOkPMik9cTE"
        guard let url = URL(string: urlBusquedaImagenes) else{
            return
        }
        let tarea = URLSession.shared.dataTask(with: url){data, response, error in
            if error != nil {
                completion(nil, error)
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                    debugPrint("No data")
                }
                return
            }
            do {
                
                let response = try JSONDecoder().decode(ApiResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.results, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                    debugPrint("Error decoding data. \(error)")
                }
            }
        }
        tarea.resume()
    }
    
    class func mostrarImagen(imageURL: String, imageView: UIImageView, completionHandler: @escaping (UIImage?) -> Void){
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
                completionHandler(image)
            }
        }.resume()
    }
    
    class func getImage(imageId: String, imageURL: String, completionHandler: @escaping (String?,UIImage?,Error?) -> Void){
        guard let url = URL(string: imageURL) else{
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completionHandler(nil,nil,error)
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completionHandler(imageId,image, nil)
            }
        }.resume()
    }
}

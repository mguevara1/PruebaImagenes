//
//  Resultado.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 13/03/23.
//

struct Result: Codable {
    let id: String
    let urls: Urls
    let likes: Int
    let user: User
}

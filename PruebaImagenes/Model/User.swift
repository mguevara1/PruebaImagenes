//
//  USER.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 13/03/23.
//

struct User: Codable {
    let username: String
    let profile_image: ProfileImage
    let name: String?
    let location: String?
    let total_photos: Int?
}

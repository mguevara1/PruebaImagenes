//
//  RespuestaApi.swift
//  PruebaImagenes
//
//  Created by Marco Guevara on 13/03/23.
//

struct ApiResponse: Codable{
    let total: Int
    let total_pages: Int
    let results: [Result]
}

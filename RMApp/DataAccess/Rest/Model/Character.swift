//
//  Character.swift
//  RMApp
//
//  Created by jorge Sanmartin on 20/11/22.
//

struct Character: Decodable {
    let id: Int
    let name: String
    let status: String
    let origin: Origin
    let image: String
}

//
//  CharactersResponse.swift
//  RMApp
//
//  Created by jorge Sanmartin on 20/11/22.
//

struct CharactersResponse: Decodable {
    let info: Info
    let results: [Character]
}

//
//  EpisodesResponse.swift
//  RMApp
//
//  Created by jorge Sanmartin on 22/11/22.
//

struct EpisodesResponse: Decodable {
    let info: Info
    let results: [Episode]
}

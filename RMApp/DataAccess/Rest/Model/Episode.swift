//
//  Episode.swift
//  RMApp
//
//  Created by jorge Sanmartin on 22/11/22.
//

import Foundation

struct Episode: Decodable {
    let id: Int
    let name: String
    let episode: String
    let date: Date
    let season: String
    
    private enum CodingKeys : String, CodingKey {
        case id
        case name
        case episode
        case date = "air_date"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.episode = try container.decode(String.self, forKey: .episode)
        self.date = try container.decode(Date.self, forKey: .date)
        let season = episode.split(separator: "E")
        self.season = season.first?.description ?? ""
    }
}

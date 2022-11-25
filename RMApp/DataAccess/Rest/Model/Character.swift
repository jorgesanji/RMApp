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
    let episodes: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case origin
        case image
        case episodes = "episode"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.status = try container.decode(String.self, forKey: .status)
        self.origin = try container.decode(Origin.self, forKey: .origin)
        self.image = try container.decode(String.self, forKey: .image)
        self.episodes = try container.decode([String].self, forKey: .episodes)
            .map { Int($0.components(separatedBy: "/").last ?? "0") ?? 0 }
    }
    
    init(id: Int, name: String, status: String, origin: Origin, image: String, episodes: [Int]){
        self.id = id
        self.name = name
        self.status = status
        self.origin = origin
        self.image = image
        self.episodes = episodes
    }
}

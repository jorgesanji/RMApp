//
//  ApiService.swift
//  RMApp
//
//  Created by jorge Sanmartin on 20/11/22.
//

import Foundation
import Combine
import OSLog

enum NetworkError: LocalizedError {
    case badURL
}

protocol ApiService {
    func getCharactersByPage(_ page: Int) -> AnyPublisher<CharactersResponse, Error>
    func getCharacterEpisodesByIds(_ ids: [Int]) -> AnyPublisher<[Episode], Error>
}

final class ApiServiceImpl: ApiService {
    
    private let decoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_us")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    func getCharactersByPage(_ page: Int) -> AnyPublisher<CharactersResponse, Error> {
        request(endpoint: .getCharactersByPage(page))
    }
    
    func getCharacterEpisodesByIds(_ ids: [Int]) -> AnyPublisher<[Episode], Error> {
        request(endpoint: .getCharacterEpisodesByIds(ids))
    }
    
    func request<T: Decodable>(endpoint: Endpoints) -> AnyPublisher<T, Error> {
        
        guard let request = endpoint.request else {
            fatalError(NetworkError.badURL.localizedDescription)
        }

        os_log("request = %@", request.url!.description)
                        
        return URLSession.shared.dataTaskPublisher(for: request).map { $0.data }
            .decode(type: T.self, decoder: decoder)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        
    }
}

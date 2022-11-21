//
//  ApiService.swift
//  RMApp
//
//  Created by jorge Sanmartin on 20/11/22.
//

import Foundation
import Combine

enum NetworkError: LocalizedError {
    case badURL
    case noData
}

protocol ApiService {
    func getCharactersByPage(_ page: Int) -> AnyPublisher<CharactersResponse, Error>
    //func getCharactersEpisodesByPage(_ page: Int) -> AnyPublisher<CharactersResponse, Error>

}

final class ApiServiceImpl: ApiService {
    
    func getCharactersByPage(_ page: Int) -> AnyPublisher<CharactersResponse, Error> {
        
        guard let request = Endpoints.getCharactersByPage(page).request else {
            fatalError(NetworkError.badURL.localizedDescription)
        }
                        
        return URLSession.shared.dataTaskPublisher(for: request).map { $0.data }
            .decode(type: CharactersResponse.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

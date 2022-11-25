//
//  RestRepository.swift
//  RMApp
//
//  Created by jorge Sanmartin on 21/11/22.
//

import Combine

protocol RestRepository {
    func getCharactersByPage(_ page: Int) -> AnyPublisher<CharactersResponse, Error>
    func getCharacterEpisodesByIds(_ ids: [Int]) -> AnyPublisher<[Episode], Error>
}

final class RestRepositoryImpl: RestRepository {
    
    private final let apiService: ApiService
    
    init(apiService: ApiService = ApiServiceImpl()) {
        self.apiService = apiService
    }
    
    func getCharactersByPage(_ page: Int) -> AnyPublisher<CharactersResponse, Error> {
        apiService.getCharactersByPage(page)
    }
    
    func getCharacterEpisodesByIds(_ ids: [Int]) -> AnyPublisher<[Episode], Error> {
        apiService.getCharacterEpisodesByIds(ids)
    }
}

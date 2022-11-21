//
//  RestRepository.swift
//  RMApp
//
//  Created by jorge Sanmartin on 21/11/22.
//

import Combine

protocol RestRepository {
    func getCharactersByPage(_ page: Int) -> AnyPublisher<CharactersResponse, Error>
}

final class RestRepositoryImpl: RestRepository {
    
    private final let apiService: ApiService
    
    init(apiService: ApiService = ApiServiceImpl()) {
        self.apiService = apiService
    }
    
    func getCharactersByPage(_ page: Int) -> AnyPublisher<CharactersResponse, Error> {
        apiService.getCharactersByPage(page)
    }
}

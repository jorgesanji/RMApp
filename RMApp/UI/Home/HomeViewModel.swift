//
//  HomeViewModel.swift
//  RMApp
//
//  Created by jorge Sanmartin on 21/11/22.
//

import Foundation
import Combine
import OSLog

enum HomeState: Equatable {
    case initial
    case loading
    case results
    case empty
    case error
}

// MARK: - HomeEvent

enum HomeEvent {
    case onAppear
    
    case retry
    case reload
    case fetchNextPage
    
    case didFetchResultsSuccessfully(_ response: CharactersResponse)
    case didFetchResultsFailure(_ error: Error)
    case didFetchResultsEmpty
}

final class HomeViewModel: BaseViewModel<HomeState, HomeEvent> {
    
    private var subscriptions = Set<AnyCancellable>()
    private var page: Int = 0
    private var maxPageCount: Int = 0
    private final let restRepository: RestRepository
    
    var data: [CharacterItemViewModel] = []
    
    init(restRepository: RestRepository = RestRepositoryImpl()) {
        self.restRepository = restRepository
        super.init(.initial)
    }
    
    override func handleEvent(_ event: HomeEvent) -> HomeState? {
        switch(state, event) {
        case (.initial, .onAppear):
            page = 1
            fetchCharacters()
            return .loading
            
        case (.loading, .didFetchResultsSuccessfully(let result)):
            self.maxPageCount = result.info.pages
            data.append(contentsOf: result.results.map {.init( id: $0.id, name: $0.name, image: $0.image, origin: $0.origin.name, status: $0.status)})
            return .results
            
        case (.results, .didFetchResultsSuccessfully(let result)):
            data.append(contentsOf: result.results.map {.init( id: $0.id, name: $0.name, image: $0.image, origin: $0.origin.name, status: $0.status)})
            return .results
            
        case (.loading, .didFetchResultsFailure(let error)):
            stateError = error
            return .error
            
        case (.loading, .didFetchResultsEmpty):
            return .empty
            
        case (.results, .didFetchResultsEmpty):
            break // Don't change the state to empty as we have some results to show to the user.
            
        case (.results, .reload):
            break
            
        case (.empty, .retry), (.error, .retry):
            fetchCharacters()
            return .loading
            
        default:
            fatalError("Event not handled...")
        }
        
        return nil
    }
    
    override func handleStateUpdate(_ oldState: HomeState, new newState: HomeState) {
        switch(oldState, newState) {
        case (.initial, .loading):
            break
        case (.loading, .results):
            break
        case (.loading, .empty):
            data = []
            stateError = nil
        case (.error, .loading):
            stateError = nil
        case (.loading, .error), (.empty, .loading):
            data = []
            page = 1
        default:
            fatalError("You lended in a misterious place... Coming from \(oldState) and trying to get to \(newState)")
        }
    }
    
    // MARK: Private
    
    private func fetchCharacters() {        
        restRepository.getCharactersByPage(page).sink {[weak self] completion in
            guard let self = self else { return }
            os_log("completion done", type: .debug)
            switch completion {
            case .failure(let error):
                self.send(event: .didFetchResultsFailure(error))
                break
            case .finished:
                break
            }
        } receiveValue: {[weak self] response in
            guard let self = self else { return }
            if response.results.isEmpty {
                self.send(event: .didFetchResultsEmpty)
            } else {
                self.send(event: .didFetchResultsSuccessfully(response))
            }
        }.store(in: &subscriptions)
    }
}

struct CharacterItemViewModel {
    let id: Int
    let name: String
    let image: String
    let origin: String
    let status: String
}

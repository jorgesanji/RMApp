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
    
    private var data: [CharacterItemViewModel] = []
    
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
            
        case (.results, .fetchNextPage):
            loadNextPage()
            break
        case (.loading, .didFetchResultsSuccessfully(let result)):
            self.maxPageCount = result.info.pages
            data.append(contentsOf: result.results.map {CharacterItemViewModelImpl(character: $0)})
            return .results
            
        case (.results, .didFetchResultsSuccessfully(let result)):
            data.append(contentsOf: result.results.map {CharacterItemViewModelImpl(character: $0)})
            return .results
            
        case (.loading, .didFetchResultsFailure(let error)):
            stateError = error
            return .error
            
        case (.loading, .didFetchResultsEmpty):
            return .empty
            
        case (.results, .didFetchResultsEmpty):
            break
            
        case (.results, .reload):
            break
            
        case (.empty, .retry), (.error, .retry):
            fetchCharacters()
            return .loading
            
        case (.results, .retry):
            fetchCharacters()
            return .results
            
        default:
            fatalError("Event not handled...")
        }
        
        return nil
    }
    
    override func handleStateUpdate(_ oldState: HomeState, new newState: HomeState) {
        switch(oldState, newState) {
        case (.initial, .loading):
            break
        case (.loading, .results), (.results, .loading):
            break
        case (.loading, .empty):
            data = []
            stateError = nil
        case (.error, .loading):
            stateError = nil
        case (.results, .results):
            stateError = nil
        case (.loading, .error), (.empty, .loading):
            data = []
            page = 1
        default:
            fatalError("You lended in a misterious place... Coming from \(oldState) and trying to get to \(newState)")
        }
    }
    
    // MARK: Public

    func getCharactersCount() -> Int {
        data.count
    }
    
    func getCharacterViewModel(at: Int) -> CharacterItemViewModel {
        data[at]
    }
    
    // MARK: Private
    
    private func loadNextPage() {
        if page < maxPageCount {
            page = page + 1
            fetchCharacters()
        }
    }
    
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

protocol CharacterItemViewModel {
    var id: Int { get }
    var name: String { get }
    var image: String { get }
    var origin: String { get }
    var status: String { get }
    var episodes: [Int] { get }
}

struct CharacterItemViewModelImpl: CharacterItemViewModel {
    let id: Int
    let name: String
    let image: String
    let origin: String
    let status: String
    let episodes: [Int]
    
    init(character: Character) {
        self.id = character.id
        self.name = character.name
        self.image = character.image
        self.origin = character.origin.name
        self.status = character.status
        self.episodes = character.episodes
    }
}

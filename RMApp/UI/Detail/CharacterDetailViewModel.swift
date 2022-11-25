//
//  CharacterDetailViewModel.swift
//  RMApp
//
//  Created by jorge Sanmartin on 22/11/22.
//

import Foundation
import Combine
import OSLog

enum DetailState: Equatable {
    case initial
    case loading
    case results
    case empty
    case error
}

// MARK: - DetailEvent

enum DetailEvent {
    case onAppear
    case onDisappear

    case retry
    case reload
    case fetchNextPage
    
    case didFetchResultsSuccessfully(_ result: [Episode])
    case didFetchResultsFailure(_ error: Error)
    case didFetchResultsEmpty
}

final class CharacterDetailViewModel: BaseViewModel<DetailState, DetailEvent> {
    
    private var subscriptions = Set<AnyCancellable>()
    private final let restRepository: RestRepository
    private final let characterItemViewModel: CharacterItemViewModel
    
    private var data: [SectionItem] = []
    
    init(itemViewModel: CharacterItemViewModel, restRepository: RestRepository = RestRepositoryImpl()) {
        self.characterItemViewModel = itemViewModel
        self.restRepository = restRepository
        super.init(.initial)
    }
    
    override func handleEvent(_ event: DetailEvent) -> DetailState? {
        switch(state, event) {
            
        case (.results, .onDisappear):
            return .empty
            
        case (.initial, .onAppear), (.results, .onAppear), (.empty, .onAppear), (.initial, .onDisappear):
            fetchEpisodes()
            return .loading
            
        case (.loading, .didFetchResultsSuccessfully(let result)), (.results, .didFetchResultsSuccessfully(let result)):
            self.data = result
                .group { $0.season }
                .sorted { $0.0 < $1.0 }
                .map { SectionItem(title: $0.0, items: $0.1) }
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
            fetchEpisodes()
            return .loading
            
        case (.error, .onDisappear), (.loading, .onDisappear), (.error, .onAppear):
            break
            
        default:
            fatalError("Event not handled...")
        }
        
        return nil
    }
    
    override func handleStateUpdate(_ oldState: DetailState, new newState: DetailState) {
        switch(oldState, newState) {
            
        case (.results, .empty):
            data = []
            break
            
        case (.initial, .loading):
            break
            
        case (.loading, .results):
            break
            
        case (.loading, .empty), (.results, .loading):
            data = []
            stateError = nil
            
        case (.error, .loading):
            stateError = nil
            
        case (.loading, .error), (.empty, .loading):
            data = []
            
        default:
            fatalError("You lended in a misterious place... Coming from \(oldState) and trying to get to \(newState)")
        }
    }
    
    // MARK: Public
    
    var title: String {
        characterItemViewModel.name
    }

    func getSeasonsCount() -> Int {
        data.count
    }
    
    func getSeasonTitle(at: Int) -> String {
        data[at].title
    }
    
    func getEpisodesCount(section: Int) -> Int {
        data[section].items.count
    }
    
    func getEpisodeModel(section: Int, row: Int) -> EpisodeItemViewModel {
        data[section].items[row]
    }
    
    // MARK: Private
    
    private func fetchEpisodes() {
        restRepository.getCharacterEpisodesByIds(characterItemViewModel.episodes)
            .sink {[weak self] completion in
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
                if response.isEmpty {
                    self.send(event: .didFetchResultsEmpty)
                } else {
                    self.send(event: .didFetchResultsSuccessfully(response))
                }
            }.store(in: &subscriptions)
    }
}


struct SectionItem {
    let title: String
    let items: [EpisodeItemViewModel]
    
    init(title: String, items: [Episode]) {
        self.title = title
        self.items = items.map{ EpisodeItemViewModelImpl(episode: $0) }
    }
}


protocol EpisodeItemViewModel {
    var title: String { get }
    var date: String { get }
    
    init(episode: Episode)
}

struct EpisodeItemViewModelImpl: EpisodeItemViewModel {
    let title: String
    let date: String
    
    init(episode: Episode) {
        self.title = episode.name
        self.date = episode.date.formatted(date: .long, time: .omitted)
    }
}

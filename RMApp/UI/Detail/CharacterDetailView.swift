//
//  CharacterDetailView.swift
//  RMApp
//
//  Created by jorge Sanmartin on 21/11/22.
//

import SwiftUI
import Combine

struct CharacterDetailView: View {
    
    @ObservedObject private var viewModel: CharacterDetailViewModel
    
    init(viewModel: CharacterDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            switch viewModel.state {
            case .error:
                ErrorView {
                    viewModel.send(event: .retry)
                }
            case .results:
                listView
            case .initial:
                emptyView
            case .empty:
                emptyView
            case .loading:
                progressView
            }
        }
        .navigationTitle(viewModel.title)
        .onAppear {
            viewModel.send(event: .onAppear)
        }
        .onDisappear {
            viewModel.send(event: .onDisappear)
        }
    }
    
    private var progressView: some View {
        ProgressView().progressViewStyle(CircularProgressViewStyle())
    }
    
    private var emptyView: some View {
        Text("empty")
    }
        
    private var listView: some View {
        List {
            ForEach((0..<viewModel.getSeasonsCount()), id: \.self) { index in
                Section(header: Text(viewModel.getSeasonTitle(at: index))) {
                    ForEach((0..<viewModel.getEpisodesCount(section: index)), id: \.self) { row in
                        EpisodeItemView(viewModel: viewModel.getEpisodeModel(section: index, row: row))
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        }
    }
}

struct EpisodeItemView: View {
    
    var viewModel: EpisodeItemViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.title)
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(3)
                .padding(.init(top: 0.5, leading: 0, bottom: 0.5, trailing: 0))
            
            Text(viewModel.date)
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .medium, design: .default))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .padding(.init(top: 0, leading: 0, bottom: 0.5, trailing: 0))
        }
    }
}

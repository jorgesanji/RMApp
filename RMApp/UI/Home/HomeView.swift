//
//  HomeView.swift
//  RMApp
//
//  Created by jorge Sanmartin on 20/11/22.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                switch viewModel.state {
                case .error:
                    ErrorView {
                        viewModel.send(event: .retry)
                    }
                case .results:
                    gridView
                case .initial:
                    emptyView
                case .empty:
                    emptyView
                case .loading:
                    progressView
                }
            }
            .navigationTitle("home")
        }
        .onAppear {
            viewModel.send(event: .onAppear)
        }
    }
    
    private var progressView: some View {
        ProgressView().progressViewStyle(CircularProgressViewStyle())
    }
    
    private var emptyView: some View {
        Text("empty")
    }
    
    private var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 10) {
                ForEach((0..<viewModel.getCharactersCount()), id: \.self) { index in
                    NavigationLink(destination:
                                    CharacterDetailView(viewModel: .init(itemViewModel: viewModel.getCharacterViewModel(at: index)))){
                        
                        CharacterItemView(viewModel: viewModel.getCharacterViewModel(at: index))
                            .frame(width: 86, height: 185)
                            .onAppear {
                                viewModel.send(event: .fetchNextPage)
                            }
                    }
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
    }
}

struct CharacterItemView: View {
    
    var viewModel: CharacterItemViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.white)
                .shadow(color: .gray, radius: 3, x: -1, y: 1)
            
            VStack {
                AsyncImage(url: URL(string: viewModel.image), content: { image in
                    image.resizable()
                }, placeholder: {
                    ProgressView()
                })
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .padding(.init(top: 0.5, leading: 5, bottom: 0, trailing: 5))
                
                Text(viewModel.name)
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.init(top: 0.5, leading: 5, bottom: 0, trailing: 5))
                
                Text(viewModel.status)
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.init(top:0.5, leading: 5, bottom: 0, trailing: 5))
                
                Text(viewModel.origin)
                    .foregroundColor(.black)
                    .font(.system(size: 10, weight: .light, design: .default))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
    }
}

struct CharacterItemView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterItemView(viewModel: CharacterItemViewModelImpl(character:
                .init(id: 1,
                      name: "Test",
                      status: "live",
                      origin: .init(name: "Barcelona", url: ""),
                      image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                      episodes: [])))
    }
}

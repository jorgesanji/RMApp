//
//  Endpoints.swift
//  RMApp
//
//  Created by jorge Sanmartin on 20/11/22.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

enum Endpoints {
    
    case getCharactersByPage(_ page: Int)
    case getCharacterEpisodesByIds(_ ids: [Int])
    
    var url: URL {
        guard let url = URL(string: "https://rickandmortyapi.com" ) else {
            fatalError("Base URL should be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getCharactersByPage:
            return "/api/character/"
        case .getCharacterEpisodesByIds(let episodes):
            return "/api/episode/" + episodes.description
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .getCharactersByPage, .getCharacterEpisodesByIds:
            return.get
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .getCharactersByPage(let page):
            return [URLQueryItem(name: "page", value: String(page))]
        default:
            return []
        }
    }
    
    var headers: [String : String] {
        var hd = [String: String]()
        hd["Content-Type"] = "application/json"
        hd["accept"] = "application/json"
        return hd
    }
    
    var request: URLRequest? {
        var component = URLComponents(url: url, resolvingAgainstBaseURL: true)
        component?.path = path
        component?.queryItems = queryItems
        guard let result = component?.url else {
            return nil
        }
        var urlRequest = URLRequest(url: result)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}

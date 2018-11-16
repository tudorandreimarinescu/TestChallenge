//
//  MovieEndPoint.swift
//  YoyoCinema
//
//  Created by Marinescu Tudor-Andrei on 13/11/2018.
//  Copyright © 2018 Marinescu Tudor-Andrei. All rights reserved.
//

import Foundation

enum NetworkEnvironment {
    case qa
    case production
    case staging
}

public enum MovieAPI {
    case recommended(id: Int)
    case popular(page: Int)
    case newMovies(page: Int)
    case video(id: Int)
    case searchMovies(criteria: String, page: Int)
}

extension MovieAPI: EndPointType {
    var environmentBaseURL: String {
        switch NetworkManager.environment {
        case .production: return "https://api.themoviedb.org/3/"
        case .qa: return "https://qa.themoviedb.org/3/"
        case .staging: return "https://staging.themoviedb.org/3/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL couldn't be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .recommended(let id):
            return "movie/\(id)/recommendations"
        case .popular:
            return "movie/popular"
        case .newMovies:
            return "movie/now_playing"
        case .video(let id):
            return "movie/\(id)/videos"
        case .searchMovies(criteria: _, page: _):
            return "search/movie"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .newMovies(let page):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: ["page" : page, "api_key" : NetworkManager.MovieAPIKey])
        case .searchMovies(criteria: let searchCriteria, page: let searchPage):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: ["api_key" : NetworkManager.MovieAPIKey, "query" : searchCriteria, "page" : searchPage])

        default:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}

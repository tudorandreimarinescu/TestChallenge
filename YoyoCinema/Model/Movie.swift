//
//  Movie.swift
//  YoyoCinema
//
//  Created by Marinescu Tudor-Andrei on 13/11/2018.
//  Copyright © 2018 Marinescu Tudor-Andrei. All rights reserved.
//

import Foundation

struct MovieAPIResponse {
    let page: Int
    let numberOfResults: Int
    let numberOfPages: Int
    let movies: [Movie]
}

extension MovieAPIResponse: Decodable {
    private enum MovieAPIResponseCodingKeys: String, CodingKey {
        case page
        case numberOfResults = "total_results"
        case numberOfPages = "total_pages"
        case movies = "results"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieAPIResponseCodingKeys.self)
        
        page = try container.decode(Int.self, forKey: .page)
        numberOfResults = try container.decode(Int.self, forKey: .numberOfResults)
        numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
        movies = try container.decode([Movie].self, forKey: .movies)
    }
}

struct Movie {
    let id: Int
    let posterPath: String?
    let title: String
    let releaseDate: String
    let overview: String?
}

extension Movie: Codable {
    
    enum MovieCodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case title
        case releaseDate = "release_date"
        case overview
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MovieCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(posterPath, forKey: .posterPath)
        try container.encode(title, forKey: .title)
        try container.encode(releaseDate, forKey: .releaseDate)
        try container.encode(overview, forKey: .overview)
    }
    
    init(from decoder: Decoder) throws {
        let movieContainer = try decoder.container(keyedBy: MovieCodingKeys.self)
        
        id = try movieContainer.decode(Int.self, forKey: .id)
        posterPath = try movieContainer.decodeIfPresent(String.self, forKey: .posterPath)
        title = try movieContainer.decode(String.self, forKey: .title)
        releaseDate = try movieContainer.decode(String.self, forKey: .releaseDate)
        overview = try movieContainer.decodeIfPresent(String.self, forKey: .overview)
        
    }
}

struct CachableMovies: Cachable, Codable {
    let store: String
    var movies: [Movie]
    
    var fileName: String {
        return "movies-\(store)"
    }
    
    enum CachableMoviesCodingKeys: String, CodingKey {
        case store
        case movies
    }
    
    init(from decoder: Decoder) throws {
        let cachedMoviesContainer = try decoder.container(keyedBy: CachableMoviesCodingKeys.self)
        
        store = try cachedMoviesContainer.decode(String.self, forKey: .store)
        movies = try cachedMoviesContainer.decode([Movie].self, forKey: .movies)
    }
    
    init(store: String = "favorites", movies: [Movie]) {
        self.store = store
        self.movies = movies
    }
}

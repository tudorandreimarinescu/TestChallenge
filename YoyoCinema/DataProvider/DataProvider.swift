//
//  DataProvider.swift
//  YoyoCinema
//
//  Created by Marinescu Tudor-Andrei on 14/11/2018.
//  Copyright © 2018 Marinescu Tudor-Andrei. All rights reserved.
//

import Foundation

class DataProvider {
    
    static let sharedInstance = DataProvider()
    
    private lazy var networkManager: NetworkManager = {
        return NetworkManager()
    }()
    
    private lazy var cacher: Cacher = {
        return Cacher(destination: .atFolder("MyFavoriteMovies"))
    }()
    
    private init() { }
    
    func addMovieToFavorites(movie: Movie, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        getFavoriteMoviesFromCache { (cachedMovies) in
            guard var cachedM = cachedMovies else {
                self.setMoviesAsFavorites(cachableMovies: CachableMovies(movies: [movie]), completion: { (success, error) in
                    completion(success, error?.localizedDescription)
                    return
                })
                return
            }
            cachedM.movies.append(movie)
            self.setMoviesAsFavorites(cachableMovies: cachedM, completion: { (success, error) in
                completion(success, error?.localizedDescription)
            })
        }
    }
    
    func removeMovieFromFavorites(movie: Movie,completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        getFavoriteMoviesFromCache { (cachedMovies) in
            guard var cachedM = cachedMovies else {
                completion(false, "No movies cached")
                return
            }
            let newMovies = cachedM.movies.filter() {
                $0.id != movie.id
            }
            cachedM.movies = newMovies
            self.setMoviesAsFavorites(cachableMovies: cachedM, completion: { (success, error) in
                completion(success, error?.localizedDescription)
            })
        }
    }
    
    func getFavoriteMovies(completion: @escaping (_ favoriteMovies: [Movie]?, _ error: String?) -> Void) {
        getFavoriteMoviesFromCache { (cachedMovies) in
            guard let cachedM = cachedMovies else {
                completion(nil, "No movies cached")
                return
            }
            completion(cachedM.movies, nil)
        }
    }
    
    private func getFavoriteMoviesFromCache(completion: @escaping (_ cachedMovies: CachableMovies?) -> Void) {
        if let favMovies: CachableMovies = cacher.load(fileName: "movies-favorites") {
            completion(favMovies)
        } else {
            completion(nil)
        }
    }
    
    private func setMoviesAsFavorites(cachableMovies: CachableMovies, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        cacher.persist(item: cachableMovies) { (url, error) in
            if error == nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    func getNewMovies(page: Int = 1, completion: @escaping ([Movie], Int, String?) -> Void) {
        networkManager.getNewMovies(page: page) { (response, error) in
            if error != nil {
                completion([], 0, error)
            }
            guard let resp = response else {
                completion([], 0, NetworkResponse.noData.rawValue)
                return
            }
            completion(resp.movies, resp.numberOfPages, nil)
        }
    }
    
    func searchMovies(searchCriteria: String, page: Int = 1, completion: @escaping ([Movie], Int, String?) -> Void) {
        networkManager.searchForMovies(searchCriteria: searchCriteria, page: page) { (response, error) in
            if error != nil {
                completion([], 0, error)
            }
            guard let resp = response else {
                completion([], 0, NetworkResponse.noData.rawValue)
                return
            }
            completion(resp.movies, resp.numberOfPages, nil)
            
        }
    }
}

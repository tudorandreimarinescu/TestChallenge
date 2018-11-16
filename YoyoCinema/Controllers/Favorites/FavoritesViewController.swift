//
//  FavoritesViewController.swift
//  YoyoCinema
//
//  Created by Marinescu Tudor-Andrei on 13/11/2018.
//  Copyright © 2018 Marinescu Tudor-Andrei. All rights reserved.
//

import UIKit

class FavoritesViewController: UITableViewController {
    
    private var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favorite Movies"
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieCellIdentifer")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func loadFavorites() {
        DataProvider.sharedInstance.getFavoriteMovies { (favMovies, error) in
            if error != nil {
                print(error!)
                self.showNoFavoritesView()
            } else {
                DispatchQueue.main.async {
                    if favMovies != nil {
                        self.movies = favMovies!
                        if self.movies.count == 0 {
                            self.tableView.reloadData()
                            self.showNoFavoritesView()
                        } else {
                            self.tableView.reloadData()
                            self.tableView.tableFooterView = nil
                        }
                    } else {
                        self.showNoFavoritesView()
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellIdentifer", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let movieCell = cell as! MovieTableViewCell
        if movies.indices.contains(indexPath.row) {
            let movie = movies[indexPath.row]
            movieCell.textLabel!.text = movie.title
            movieCell.detailTextLabel!.text = movie.releaseDate
            movieCell.backgroundColor = .green
            if let imagePath = movie.posterPath {
                movieCell.imageURL = URL(string: "https://image.tmdb.org/t/p/w92\(imagePath)")
            } else {
                movieCell.imageURL = nil
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! MovieTableViewCell).cancelImageDownload()
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if movies.indices.contains(indexPath.row) {
            let movie = movies[indexPath.row]
            removeFavorite(movie: movie, for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movieDetailsVC = UIStoryboard.Main.instantiateMovieDetailsViewController()
        movieDetailsVC.movie = movies[indexPath.row]
        navigationController?.pushViewController(movieDetailsVC, animated: true)
    }
    
    private func showNoFavoritesView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 300))
        let label = UILabel(frame: view.frame.insetBy(dx: 10, dy: 10))
        label.text = "No favorites!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        label.minimumScaleFactor = 0.4
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.center = view.center
        view.addSubview(label)
        tableView.tableFooterView = view
    }
    
    private func removeFavorite(movie: Movie, for indexPath: IndexPath) {
        DataProvider.sharedInstance.removeMovieFromFavorites(movie: movie) { (success, error) in
            if error != nil {
                print(error!)
            } else {
                self.loadFavorites()
            }
        }
    }
    
}

//
//  MovieListViewController.swift
//  YoyoCinema
//
//  Created by Marinescu Tudor-Andrei on 13/11/2018.
//  Copyright © 2018 Marinescu Tudor-Andrei. All rights reserved.
//

import UIKit

class MovieListViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    //MARK: --- Local Variables ---
    private var movies = [Movie]()
    private var favoriteMovies = [Movie]()
    private var page = 0
    private var maxPage = 1000
    
    var loadInProgress = false
    var searchQuery:String?
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: --- ViewController Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Movies"
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieCellIdentifer")
        setupRefreshControl()
        setupSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
        loadMovies(currentPage: page)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if movies.count > 20 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            movies.removeSubrange(Range(uncheckedBounds: (lower: 20, upper: movies.count - 1)))
            tableView.reloadData()
        }
    }
    
    //MARK: --- ViewController Setup ---
    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search movies"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
   private func setupRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshMovies), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    @objc func refreshMovies() {
        page = 0
        loadMovies(currentPage: page)
    }
    
    //MARK: --- Movie Fetch ---
  private func loadFavorites() {
        DataProvider.sharedInstance.getFavoriteMovies { (fMovies, error) in
            if error != nil {
                print(error!)
            } else {
                if let favMovies = fMovies {
                    self.favoriteMovies = favMovies
                }
            }
        }
    }
    
    private func isInFavorites(movie: Movie) -> Bool {
        if favoriteMovies.count == 0 {
            return false
        }
        var isFav = false
        favoriteMovies.forEach {
            if $0.id == movie.id {
                isFav = true
            }
        }
        return isFav
    }
    
   private func loadMovies(currentPage: Int) {
        if loadInProgress || currentPage >= maxPage {
            return
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 70))
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = .gray
        indicator.center = view.center
        indicator.startAnimating()
        view.addSubview(indicator)
        tableView.tableFooterView = view
        self.loadInProgress = true
        if let query = self.searchQuery {
            DataProvider.sharedInstance.searchMovies(searchCriteria: query, page: currentPage + 1) { (movies, pages, error) in
                DispatchQueue.main.async {
                    self.handleMoviesResponse(movies: movies, pages: pages, error: error)
                }
            }
        }
        else {
            DataProvider.sharedInstance.getNewMovies(page: currentPage + 1) { (movies, pages, error) in
                DispatchQueue.main.async {
                    self.handleMoviesResponse(movies: movies, pages: pages, error: error)
                }
            }
        }
    }
    
    private func handleMoviesResponse(movies:[Movie], pages:Int, error:String?) {
        loadInProgress = false
        if tableView.refreshControl?.isRefreshing ?? false {
            tableView.refreshControl?.endRefreshing()
        }
        tableView.tableFooterView = nil
        if error != nil {
            print(error ?? "")
            return
        }
        page += 1
        maxPage = min(pages, self.maxPage)
        let count = self.movies.count
        let additional = movies.count
        var paths = [IndexPath]()
        for i in count..<(count + additional) {
            paths += [IndexPath(row: i, section: 0)]
        }
        self.movies += movies
        tableView.insertRows(at: paths, with: .fade)
        if self.movies.count == 0 {
            showNoResultsView()
        }
        else {
            tableView.tableFooterView = nil
        }
    }
    
    private func handleMovieFavStatus(movie: Movie, for indexPath: IndexPath) {
        if !isInFavorites(movie: movie) {
            DataProvider.sharedInstance.addMovieToFavorites(movie: movie) { (success, error) in
                if error != nil {
                    print(error!)
                } else {
                    self.loadFavorites()
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        } else {
            DataProvider.sharedInstance.removeMovieFromFavorites(movie: movie) { (success, error) in
                if error != nil {
                    print(error!)
                } else {
                    self.loadFavorites()
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
    
    
    private func showNoResultsView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 300))
        let label = UILabel(frame: view.frame.insetBy(dx: 10, dy: 10))
        label.text = (self.searchQuery ?? "").isEmpty ? "No results!" : "Your query:\n'" + self.searchQuery! + "'\nreturned no results"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        label.minimumScaleFactor = 0.4
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.center = view.center
        view.addSubview(label)
        tableView.tableFooterView = view
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
            movieCell.backgroundColor = isInFavorites(movie: movie) ? .green : .white
            if let imagePath = movie.posterPath {
                movieCell.imageURL = URL(string: "https://image.tmdb.org/t/p/w92\(imagePath)")
            } else {
                movieCell.imageURL = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            loadMovies(currentPage:page)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movieDetailsVC = UIStoryboard.Main.instantiateMovieDetailsViewController()
        movieDetailsVC.movie = movies[indexPath.row]
        navigationController?.pushViewController(movieDetailsVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! MovieTableViewCell).cancelImageDownload()
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if movies.indices.contains(indexPath.row) {
            let movie = movies[indexPath.row]
            handleMovieFavStatus(movie: movie, for: indexPath)
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    fileprivate func filterContentForSearchText(_ searchText: String) {
        searchQuery = searchText
        if movies.count > 0 {
            tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: false)
        }
        maxPage = 1000
        movies = []
        page = 0
        tableView.reloadData()
        loadMovies(currentPage: page)
    }
    
    private func cancelSearch(reload: Bool = true) {
        navigationItem.leftBarButtonItem = nil
        searchQuery = nil
        movies = []
        page = 0
        maxPage = 1000
        if reload {
            tableView.reloadData()
            loadMovies(currentPage: page)
        }
    }
    
}

private extension MovieListViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= movies.count - 1 
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

extension MovieListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBarIsEmpty() {
            filterContentForSearchText(searchBar.text!)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearch(reload: true)
    }
}

extension MovieListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if !searchBarIsEmpty() {
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
}

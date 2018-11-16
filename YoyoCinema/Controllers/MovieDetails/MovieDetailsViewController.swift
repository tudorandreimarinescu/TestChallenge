//
//  MovieDetailsViewController.swift
//  YoyoCinema
//
//  Created by Marinescu Tudor-Andrei on 13/11/2018.
//  Copyright © 2018 Marinescu Tudor-Andrei. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieReleaseDateLabel: UILabel!
    
    @IBOutlet weak var movieDescriptionTextView: UITextView!
    
    var imageLoadDataTask:URLSessionDataTask?
    
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigationItem.title = "Details"
    }
    
    private func setupUI() {
        if movie != nil {
            
            imageLoadDataTask = movieImageView.downloadedFrom(url: URL(string: "https://image.tmdb.org/t/p/original\(movie?.posterPath ?? "/wwemzKWzjKYJFfCeiB57q3r4Bcm.png")")!)
            movieTitleLabel.text = movie!.title
            movieReleaseDateLabel.text = "Release date: \(movie!.releaseDate)"
            movieDescriptionTextView.text = movie!.overview
        }
    }
    
    
}

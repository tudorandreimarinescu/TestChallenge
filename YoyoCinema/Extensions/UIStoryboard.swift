//
//  UIStoryboard.swift
//  YoyoCinema
//
//  Created by Marinescu Tudor-Andrei on 13/11/2018.
//  Copyright © 2018 Marinescu Tudor-Andrei. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    struct Main {
        
        static func instantiateMovieDetailsViewController() -> MovieDetailsViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MovieDetailsVC") as! MovieDetailsViewController
            return controller
        }
    }
    
}

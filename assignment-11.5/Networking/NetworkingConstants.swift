//
//  NetworkingConstants.swift
//  assignment
//
//  Created by Mughees Mustafa on 03/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import Foundation
enum APIEndPoint {
    static let base = "https://api.themoviedb.org/3/"
    static let movieList = APIEndPoint.base + "movie/popular"
    static let searchMovie = APIEndPoint.base + "search/movie"
    
    static let imageBase = "https://image.tmdb.org/t/p/w200/"
    static let imageBase400 = "https://image.tmdb.org/t/p/w400/"
}


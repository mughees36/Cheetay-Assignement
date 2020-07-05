//
//  MovieListModel.swift
//  assignment
//
//  Created by Mughees Mustafa on 03/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import Foundation

// MARK: - MovieListModel
struct MovieListModel: Codable {
    let page, totalResults, totalPages: Int
    let results: [MovieListItem]
    
    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
}

// MARK: - Result
struct MovieListItem: Codable {
    
    let id: Int
    let posterPath: String?
    let title: String
    let releaseDate: String
    let overview: String
    
    enum CodingKeys: String, CodingKey {
        
        case posterPath = "poster_path"
        case id
        case title
        case releaseDate = "release_date"
        case overview
    }
}

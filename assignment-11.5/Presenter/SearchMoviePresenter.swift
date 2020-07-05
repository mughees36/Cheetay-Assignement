//
//  SearchMoviePresenter.swift
//  assignment-11.5
//
//  Created by Mughees Mustafa on 04/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import Foundation
class SearchMoviePresenter {
    
    private let movieService: MovieService
    weak private var movieSearchViewDelegate : MovieSearchViewDelegate?
    var arrayMovies: [MovieListItem]? = nil
    var totalPages = 10
    
    init(movieService: MovieService ) {
        self.movieService = movieService
    }
    
    func viewDidLoad() {
        if let arraySuggestions = DefaultsManager.shared.getSuggestions() {
            movieSearchViewDelegate?.showSuggestions(array: arraySuggestions)
        }
    }
    
    func setViewDelegate(movieListViewDelegate:MovieSearchViewDelegate?){
        self.movieSearchViewDelegate = movieListViewDelegate
    }
    
    func userTappedOnSuggestion(text: String) {
        movieSearchViewDelegate?.hideSuggestions()
        searchMoviesWith(query: text, page: 1)
    }
    
    func searchMoviesWith(query: String?, page: Int) {
        
        guard let text = query, !text.isEmpty else {
            arrayMovies?.removeAll()
            movieSearchViewDelegate?.displayMoviesWith(arrayMovies: nil)
            if let arraySuggestions = DefaultsManager.shared.getSuggestions() {
                movieSearchViewDelegate?.showSuggestions(array: arraySuggestions)
            }
            return
        }
        
        performSearchWith(text, page)
    }
    
    fileprivate func performSearchWith(_ text: String, _ page: Int) {
        
        guard Network.reachability.isConnectedToNetwork else {
            movieSearchViewDelegate?.showErrorAlert(description: "Not connected to internet"); return
        }
        
        movieService.searchMoviesWith(query: text, page: page) {[weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let model):
                print("model: \(model)")
                
                if page > 1 { strongSelf.arrayMovies?.append(contentsOf: model.results) }
                else { strongSelf.arrayMovies = model.results }
                
                guard let resultsArray = strongSelf.arrayMovies else {
                    strongSelf.movieSearchViewDelegate?.showErrorAlert(description: "No Results Found"); return
                }
                
                strongSelf.totalPages = model.totalPages
                strongSelf.movieSearchViewDelegate?.displayMoviesWith(arrayMovies: resultsArray)
                
                if resultsArray.count == 0 {
                    strongSelf.movieSearchViewDelegate?.showErrorAlert(description: "No Movies Found")
                } else {
                    strongSelf.saveSearchSuggestion(text: text)
                }
                
                
            case .failure(let error):
                print("error: \(error)")
                strongSelf.movieSearchViewDelegate?.showErrorAlert(description: error.localizedDescription)
            }
        }
    }
    
    func saveSearchSuggestion(text: String) {
        DefaultsManager.shared.addSuggestion(text: text)
    }
}


protocol MovieSearchViewDelegate: class {
    func displayMoviesWith(arrayMovies: [MovieListItem]?)
    func showErrorAlert(description: String)
    func showSuggestions(array: [String])
    func hideSuggestions()
}

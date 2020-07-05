//
//  MovieListPresenter.swift
//  assignment
//
//  Created by Mughees Mustafa on 03/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import Foundation
class MovieListPresenter {
    
    private let movieService: MovieService
    weak private var movieListViewDelegate : MovieListViewDelegate?
    var arrayMovies: [MovieListItem]? = nil
    var coreDataManager: CoreDataManager? = nil
    
    init(movieService: MovieService, coreDataManager: CoreDataManager ) {
        self.movieService = movieService
        self.coreDataManager = coreDataManager
    }
    
    func setViewDelegate(movieListViewDelegate:MovieListViewDelegate?){
        self.movieListViewDelegate = movieListViewDelegate
    }
    
    func viewDidLoad() {
        if let cachedMovies = coreDataManager?.getArrayOfMovies(entityName: Constant.EntityName.Movies).1 {
            let mappedMovies = cachedMovies.compactMap({ (movieItem) -> MovieListItem? in
                return movieItem ?? nil
            })
            self.arrayMovies = mappedMovies
            movieListViewDelegate?.displayMoviesWith(arrayMovies: mappedMovies)
        }
        fetchAndDisplayMovies(page: 1)
        let favoriteMovies = getAllFavoriteMovies()
        movieListViewDelegate?.processFavoriteArray(Of: favoriteMovies)
    }
    
    //MARK:- Favorites
    
    func getAllFavoriteMovies() -> [MovieListItem?]? {
        let (success, arrayMovies, message) = coreDataManager!.getArrayOfMovies(entityName: Constant.EntityName.Favorites)
        print("sucess of \(#function): \(success)")
//        print("arrayMovies: \(arrayMovies as Any)")
        print("message: \(message as Any)")
        return arrayMovies
    }
    
    func btnFavoriteTappedFor(movie: MovieListItem, markedFavorite: Bool) {
        markedFavorite ? saveFavoriteInDB(movie: movie) : removeFavoriteFromDB(movie: movie)
        movieListViewDelegate?.processFavoriteArray(Of: getAllFavoriteMovies())
    }
    
    func removeFavoriteFromDB(movie: MovieListItem) {
        let (removed, message) = CoreDataManager.shared.removeFavoriteFromDB(movie: movie)
        movieListViewDelegate?.processFavoriteArray(Of: getAllFavoriteMovies())
        print("removed: \(removed), message: \(message)")
    }
    
    func saveFavoriteInDB(movie: MovieListItem) {
        let (removed, message) = CoreDataManager.shared.saveMovieInDB(movie: movie, for: coreDataManager!.entityNameFavorites)
        movieListViewDelegate?.processFavoriteArray(Of: getAllFavoriteMovies())
        print("saved: \(removed), message: \(message)")
    }
    
    //MARK:- API Requests
    func fetchAndDisplayMovies(page: Int) {
        guard Network.reachability.isConnectedToNetwork else {
            movieListViewDelegate?.showErrorAlert(description: "Not connected to internet"); return
        }
        movieService.fetchMovieList(page: page) {[weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let model):
                print("model: \(model)")
                
                if page > 1 { strongSelf.arrayMovies?.append(contentsOf: model.results) }
                else { strongSelf.arrayMovies = model.results }
                guard let resultsArray = strongSelf.arrayMovies else {
                    strongSelf.movieListViewDelegate?.showErrorAlert(description: "No Results Found"); return
                }
                strongSelf.movieListViewDelegate?.displayMoviesWith(arrayMovies: resultsArray)
                strongSelf.cacheForOfflineView(arrayMovies: resultsArray)
                
            case .failure(let error):
                print("error: \(error)")
                strongSelf.movieListViewDelegate?.showErrorAlert(description: error.localizedDescription)
            }
        }
    }
    
    func cacheForOfflineView(arrayMovies: [MovieListItem] ) {
        DispatchQueue.main.async {
            self.coreDataManager?.saveForCache(arrayMovies: arrayMovies)
        }
    }
    
}

protocol MovieListViewDelegate: class {
    func displayMoviesWith(arrayMovies: [MovieListItem])
    func showErrorAlert(description: String)
    func processFavoriteArray(Of Movies: [MovieListItem?]? )
}

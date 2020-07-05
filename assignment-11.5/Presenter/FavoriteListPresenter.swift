//
//  FavoriteListPresenter.swift
//  assignment-11.5
//
//  Created by Mughees Mustafa on 05/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import Foundation
class FavoriteListPresenter {
    
    weak private var favoriteListViewDelegate : FavoriteListViewDelegate?
    var arrayMovies: [MovieListItem]? = nil
    var coreDataManager: CoreDataManager? = nil
    
    init(coreDataManager: CoreDataManager ) {
        
        self.coreDataManager = coreDataManager
    }
    
    func setViewDelegate(favoriteListViewDelegate:FavoriteListViewDelegate?){
        self.favoriteListViewDelegate = favoriteListViewDelegate
    }
    
    func getAllFavoriteMovies() {
            let (success, arrayMovies, message) = coreDataManager!.getArrayOfMovies(entityName: Constant.EntityName.Favorites)
            print("sucess of \(#function): \(success)")
    //        print("arrayMovies: \(arrayMovies as Any)")
            print("message: \(message as Any)")
        
        
        guard let moviesList = arrayMovies else{
            favoriteListViewDelegate?.showErrorAlert(description: "No Results Found")
            return
        }
        
        favoriteListViewDelegate?.displayFavoriteMoviesWith(arrayMovies:moviesList)
        
    }
    
}
protocol FavoriteListViewDelegate: class {
    
    func displayFavoriteMoviesWith(arrayMovies: [MovieListItem?])
    func showErrorAlert(description: String)
    func processFavoriteArray(Of Movies: [MovieListItem?]? )
}

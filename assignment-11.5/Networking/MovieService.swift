//
//  MovieService.swift
//  assignment
//
//  Created by Mughees Mustafa on 03/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import Foundation
class MovieService {
    
    let networkService = NetworkService.shared
    
    func searchMoviesWith(query: String, page: Int, callback: @escaping (Result<MovieListModel, NetworkError>) -> Void ) {
        
        let urlStr = APIEndPoint.searchMovie
        networkService.getRequestWithUrl(urlStr: urlStr, apiKey: AppConfig.apiKey, queryString: query, pageNum: page) { (result) in
            switch result {
            case .success(let data):
                print(data)
                do {
                    let model = try JSONDecoder().decode(MovieListModel.self, from: data)
                    callback(.success(model))
                } catch {
                    print("Decoding error occured in \(#function), error: \(error)")
                    let responseString = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print("ResponseString: \(responseString as Any)")
                    callback(.failure(.decodingFailed))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func fetchMovieList(page: Int, callback: @escaping (Result<MovieListModel, NetworkError>) -> Void ) {
        
        networkService.getRequestWithUrl(urlStr: APIEndPoint.movieList, apiKey: AppConfig.apiKey, pageNum: page) { (result) in
            switch result {
            case .success(let data):
                print(data)
                do {
                    let model = try JSONDecoder().decode(MovieListModel.self, from: data)
                    callback(.success(model))
                } catch {
                    print("Decoding error occured in \(#function), error: \(error.localizedDescription)")
                    callback(.failure(.decodingFailed))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

//
//  NetworkService.swift
//  assignment
//
//  Created by Mughees Mustafa on 02/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import Foundation
class NetworkService {
    private init() { }
    static let shared = NetworkService()
    
    func getRequestWithUrl(urlStr: String, apiKey: String, queryString: String? = nil, pageNum: Int? = nil, callback: @escaping (Result<Data, NetworkError>) -> Void ) {
        
        guard var urlComponents = URLComponents(string: urlStr) else {
            callback(.failure(.badUrl)); return
        }
        
        var query = "api_key=" + apiKey
        if let pageInt = pageNum {
            query += "&page=" + String(pageInt)
        }
        if let queryString = queryString {
            query += "&query=" + queryString
        }
        urlComponents.query = query
        guard let url = urlComponents.url else {
            callback(.failure(.badUrl)); return
        }
        
        let request = NSMutableURLRequest.init(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        guard Network.reachability.isConnectedToNetwork else {
            callback(.failure(.notConnectedToInternet))
            return
        }
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, taskError) in
            if let error = taskError  {
                
                print("error occured in dataTask, urlStr: \(urlStr)" + "\nerror:  \(error)")
                let jsonString = try? JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments)
                print(jsonString as Any)
                callback(.failure(.requestFailed))
                
            } else if let data = data {
                
                callback(.success(data))
            }
        }
        dataTask.resume()
    }
}

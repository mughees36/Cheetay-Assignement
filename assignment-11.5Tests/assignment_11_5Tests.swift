//
//  assignment_11_5Tests.swift
//  assignment-11.5Tests
//
//  Created by Mughees Mustafa on 04/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import XCTest
@testable import Assignment_11_5

class assignment_11_5Tests: XCTestCase {

    var presenter: SearchMoviePresenter? = nil
    var movieService = MovieService.init()
    
    override func setUpWithError() throws {
        presenter = SearchMoviePresenter.init(movieService: MovieService.init())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let expectation = XCTestExpectation.init(description: "API will responsd")
        

        
        movieService.searchMoviesWith(query: "A", page: 1) { (result) in
            
            switch result {
            case .success(let model):
                print("model: \(model)")
                assert(model.results.count > 0 )
                
            case .failure(let error):
                print("error: \(error)")
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 20)
    }

}

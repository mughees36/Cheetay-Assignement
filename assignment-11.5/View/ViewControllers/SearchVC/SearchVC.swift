//
//  SecondViewController.swift
//  assignment
//
//  Created by Mughees Mustafa on 02/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {

    //MARK:- OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var arrayMovies: [MovieListItem]? = nil
    let cellID = String.init(describing: MovieTableViewCell.self)
    
    let presenter = SearchMoviePresenter.init(movieService: MovieService.init())
    var currentPage = 1
    var requestInProgress = false
    var showSuggestions = false
    var arraySuggestions: [String]? = nil
    var timer = Timer()
    
    //MARK:- VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib.init(nibName: cellID, bundle: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.register(cellNib, forCellReuseIdentifier: cellID)
        
        presenter.setViewDelegate(movieListViewDelegate: self)
        presenter.viewDidLoad()
        setupSearchController()
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

//MARK:- MovieSearchViewDelegate
extension SearchVC : MovieSearchViewDelegate {
    
    func showSuggestions(array: [String]) {
        showSuggestions = true
        arraySuggestions = array.reversed()
        tableView.reloadData()
    }
    
    func hideSuggestions() {
        showSuggestions = false
        tableView.reloadData()
    }
    
    func displayMoviesWith(arrayMovies: [MovieListItem]?) {
        requestInProgress = false
        showSuggestions = false
        self.arrayMovies = arrayMovies
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func showErrorAlert(description: String) {
        requestInProgress = false
        showErrorAlert(title: "Error while fetching movies", description: description)
    }
}

//MARK:- UIScrollViewDelegate
extension SearchVC: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tableView {
            
            let condition = ( (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            if condition && !requestInProgress  {
                currentPage += 1
                requestInProgress = true
                presenter.searchMoviesWith(query: searchController.searchBar.text, page: currentPage)
            }
        }
    }
}

//MARK:- UISearchBarDelegate
extension SearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

//MARK:- UISearchResultsUpdating
extension SearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("updateSearchResults called with text: \(searchController.searchBar.text as Any)")
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.63, repeats: false, block: { [weak self ](timer) in
            guard let self = self else { return }
            self.requestInProgress = true
            self.presenter.searchMoviesWith(query: searchController.searchBar.text, page: self.currentPage)
        })
        
    }
}

//MARK:- UITableViewDataSource, UITableViewDelegate
extension SearchVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showSuggestions ? arraySuggestions?.count ?? 0 : arrayMovies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showSuggestions {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as UITableViewCell
            cell.imageView?.image = UIImage.init(named: "history")
            cell.textLabel?.text = arraySuggestions?[indexPath.row]
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MovieTableViewCell
            guard let arrayViewModel = arrayMovies else { return cell }
            cell.setupWith(model: arrayViewModel[indexPath.row])
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return showSuggestions ? 40 : 400
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showSuggestions {
            guard let suggestions = arraySuggestions else { return }
            searchController.searchBar.text = suggestions[indexPath.row]
            presenter.userTappedOnSuggestion(text: suggestions[indexPath.row])
        }
    }
}

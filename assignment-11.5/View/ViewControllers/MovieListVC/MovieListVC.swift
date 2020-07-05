//
//  FirstViewController.swift
//  assignment
//
//  Created by Mughees Mustafa on 02/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import UIKit

class MovieListVC: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    //MARK:- OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    let presenter = MovieListPresenter(movieService: MovieService.init(), coreDataManager: CoreDataManager.shared)
    
    let cellID = String.init(describing: MovieCollectionViewCell.self)
    var arrayMovies: [MovieListItem]? = nil
    var requestInProgress = false { didSet { toggleShowLoader(flag: requestInProgress) }}
    var currentPage = 1
    var arrayFavoriteMovies: [MovieListItem?]? = nil
    
    //MARK:- VIEW LIFE CYCELE
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib.init(nibName: cellID, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: cellID)
        presenter.setViewDelegate(movieListViewDelegate: self)
        

        requestInProgress = true
        presenter.viewDidLoad()
    }
     override func viewWillAppear(_ animated: Bool) {
         
          NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(notification:)), name: Notification.Name("FavoriteDeleted"), object: nil)
        
       }
    
    @objc func reloadData(notification: Notification) {
        
        presenter.viewDidLoad()

        
        
    }
    func toggleShowLoader(flag: Bool) {
        DispatchQueue.main.async {
            self.loadingIndicator.isHidden = !flag
            flag ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
        }
    }
}

//MARK:- MovieListViewDelegate
extension MovieListVC: MovieListViewDelegate {
    
    func processFavoriteArray(Of Movies: [MovieListItem?]?) {
        arrayFavoriteMovies = Movies
        collectionView.reloadData()
    }
    
    func displayMoviesWith(arrayMovies: [MovieListItem]) {
    
        requestInProgress = false
        self.arrayMovies = arrayMovies
        DispatchQueue.main.async { self.collectionView.reloadData() }
    }
    
    func showErrorAlert(description: String) {
        requestInProgress = false
        showErrorAlert(title: "Error while fetching movies", description: description)
    }
}

extension MovieListVC: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == collectionView {
            
            let condition = ( (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            if condition && !requestInProgress  {
                currentPage += 1
                requestInProgress = true
                presenter.fetchAndDisplayMovies(page:currentPage)
            }
        }
    }
}

//MARK:- UICollectionViewDataSource, UICollectionViewDelegate
extension MovieListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayMovies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MovieCollectionViewCell
        guard let arrayMovies = arrayMovies else { return cell }
        let movie = arrayMovies[indexPath.row]
        cell.setupWith(model: movie)
        cell.btnFav.tag = indexPath.row
        cell.btnFav.addTarget(self, action: #selector(self.btnFavTapped(_:)), for: .touchUpInside)
        let isFavorite = arrayFavoriteMovies?.contains(where: { (favMovie) -> Bool in return favMovie?.id == movie.id}) ?? false
        cell.isFavorite = isFavorite
        cell.btnFav.isSelected = isFavorite
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
           let viewController = MovieDetailVC.instantiateFromStoryboard()
           viewController.movieDetail = arrayMovies?[indexPath.row]
           self.navigationController?.pushViewController(viewController, animated: true)
           
       }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8 + 5
        let width = (collectionView.bounds.width / 2) - spacing
        let height: CGFloat = 237
        return CGSize.init(width: width, height: height)
    }
    
    @objc func btnFavTapped(_ sender: UIButton) {
        guard let arrayMovies = arrayMovies else { return }
        presenter.btnFavoriteTappedFor(movie: arrayMovies[sender.tag], markedFavorite: !sender.isSelected)
    }
     
}



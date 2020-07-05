//
//  MovieDetailVC.swift
//  assignment-11.5
//
//  Created by Mughees Mustafa on 05/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import UIKit


class MovieDetailVC: UIViewController {
    


    @IBOutlet weak var imgFavorite: UIImageView!
    
    @IBOutlet weak var imgMoviePoster: UIImageView!
    @IBOutlet weak var lblMovieName: UILabel!
    @IBOutlet weak var lblReleaseDate: UILabel!
    @IBOutlet weak var lblMovieOverview: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnFavorite: UIButton!
    
    var movieDetail:MovieListItem?
    var arrayFavoriteMovies: [MovieListItem?]? = nil
    
    var imageFav = UIImage.init(named: "heart-filled")
    var imageNormal = UIImage.init(named: "heart-black")
    
    var isFavorite = false {
        didSet { imgFavorite.image = isFavorite ? imageFav : imageNormal }
    }

    let presenter = MovieListPresenter(movieService: MovieService.init(), coreDataManager: CoreDataManager.shared)
    
    //MARK:- VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        guard let movieDetailItem = movieDetail else { return}
        
        self.title = movieDetailItem.title
        
        self.checkFavorite()
        

        
        if let posterPath = movieDetailItem.posterPath,
            let url = URL.init(string: APIEndPoint.imageBase + posterPath) {
            imgMoviePoster.sd_setImage(with: url, completed: nil)
        }
        
        lblMovieName.text = "Movie Name: \(movieDetailItem.title)"
        lblReleaseDate.text = "Release Date: \(movieDetailItem.releaseDate)"
        lblMovieOverview.text = "Overview: \(movieDetailItem.overview)"
//        isFavorite == true ? (imgFavorite.image = imageFav) : (imgFavorite.image = imageNormal)

        
        
        self.checkOrientation()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            
            self.scrollView.isScrollEnabled = true
            
        } else {
            self.scrollView.isScrollEnabled = false
        }
    }
    
    
    
    func checkOrientation(){
        
        
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {return}

        
        if orientation.isLandscape {
            self.scrollView.isScrollEnabled = true

            
        } else {

            self.scrollView.isScrollEnabled = false

        }
        
    }
    
    func checkFavorite(){
        arrayFavoriteMovies = presenter.getAllFavoriteMovies()
        let isPresent = arrayFavoriteMovies?.contains(where: { (favMovie) -> Bool in return favMovie?.id == movieDetail?.id}) ?? false
        isFavorite = isPresent
        
    }

    @IBAction func btnFavorite(_ sender: Any) {
        
        isFavorite == true ? (isFavorite = false) : (isFavorite = true)
        guard let movie = movieDetail else { return }
        presenter.btnFavoriteTappedFor(movie: movie, markedFavorite: isFavorite)
        NotificationCenter.default.post(name: Notification.Name("FavoriteDeleted"), object: nil)

        
    }
}


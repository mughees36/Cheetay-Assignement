//
//  FavoriteVC.swift
//  assignment-11.5
//
//  Created by Mughees Mustafa on 05/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import UIKit

class FavoriteVC: UIViewController {
   

    @IBOutlet weak var tblFavorite: UITableView!
    @IBOutlet weak var lblFavoriteEmpty: UILabel!
    
    var arrayMovies: [MovieListItem]? = nil
    let cellID = String.init(describing: MovieTableViewCell.self)
    let presenter = MovieListPresenter(movieService: MovieService.init(), coreDataManager: CoreDataManager.shared)
    
    //MARK:- VIEW LIFE CYCELE

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib.init(nibName: cellID, bundle: nil)
        tblFavorite.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tblFavorite.register(cellNib, forCellReuseIdentifier: cellID)
        
        
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
      
        super.viewWillAppear(animated)
        arrayMovies = presenter.getAllFavoriteMovies() as? [MovieListItem]
        
        self.favoriteMoviesCount()
    }
    
    func favoriteMoviesCount(){
        
        if arrayMovies?.count == 0 {
            
            tblFavorite.isHidden = true
            lblFavoriteEmpty.isHidden = false
            
        }else{
            
            tblFavorite.isHidden = false
            lblFavoriteEmpty.isHidden = true
            DispatchQueue.main.async {[weak self] in
                       self?.tblFavorite.reloadData()
                   }
        }
        
    }
    
}
//MARK:- UITableViewDataSource, UITableViewDelegate

extension FavoriteVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           
        return arrayMovies?.count ?? 0
        
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MovieTableViewCell
            guard let arrayViewModel = arrayMovies else { return cell }
            cell.setupWith(model: arrayViewModel[indexPath.row])
        
            cell.btnFav.tag = indexPath.row
            cell.btnFav.addTarget(self, action: #selector(self.btnFavTapped(_:)), for: .touchUpInside)
            cell.isFavorite = true
//        cell.btnFav.isSelected = true
            return cell
        
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = MovieDetailVC.instantiateFromStoryboard()
        viewController.movieDetail = arrayMovies?[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
       
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 400
       }
    
    
    @objc func btnFavTapped(_ sender: UIButton) {
        guard let arrayMovies = arrayMovies else { return }
        presenter.btnFavoriteTappedFor(movie: arrayMovies[sender.tag], markedFavorite: false)
        self.arrayMovies = presenter.getAllFavoriteMovies() as? [MovieListItem]
         DispatchQueue.main.async {[weak self] in
            self?.tblFavorite.reloadData()
        }
        self.favoriteMoviesCount()
        NotificationCenter.default.post(name: Notification.Name("FavoriteDeleted"), object: nil)

    }
}

//
//  MovieCollectionViewCell.swift
//  assignment
//
//  Created by Mughees Mustafa on 03/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import UIKit
import SDWebImage

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgViewPoster: UIImageView!
    @IBOutlet weak var lblMovieName: UILabel!
    @IBOutlet weak var lblReleaseDate: UILabel!
    
    @IBOutlet weak var imgViewFav: UIImageView!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var viewFavHeart: UIView!
    var imageFav = UIImage.init(named: "heart-filled")
    var imageNormal = UIImage.init(named: "heart-black")
    
    var isFavorite = false {
        didSet { imgViewFav.image = isFavorite ? imageFav : imageNormal }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgViewPoster.roundCorners(radius: 8)
        viewFavHeart.roundCorners(radius: 13.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgViewPoster.roundCorners(radius: 8)
    }
    
    func setupWith(model: MovieListItem) {
        lblMovieName.text = model.title
        lblReleaseDate.text = model.releaseDate
        
        if let posterPath = model.posterPath,
            let url = URL.init(string: APIEndPoint.imageBase + posterPath) {
            imgViewPoster.sd_setImage(with: url, completed: nil)
        }
    }

}

//
//  SQLiteManager.swift
//  assignment-11.5
//
//  Created by Mughees Mustafa on 05/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import UIKit
import CoreData
class CoreDataManager {
    private init() {}
    static let shared = CoreDataManager()
     
    var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var managedContext: NSManagedObjectContext? {
        return appDelegate?.persistentContainer.viewContext
    }
    
    let entityNameFavorites = "Favorites"
    let entityNameMovies = "Movies"
    
    private func fetchArrayOfManagedObjects(for EntityName: String) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: EntityName)
        do {
            let arrayFavorites = try managedContext?.fetch(fetchRequest)
            let arrayObjects = arrayFavorites as! [NSManagedObject]
            return arrayObjects
        } catch {
            print("could not get array of favorites from core data, error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func removeFavoriteFromDB(movie: MovieListItem) -> (Bool, String) {
        guard let arrayObjects = fetchArrayOfManagedObjects(for: entityNameFavorites) else {
            return(false, "No movies to delete")
        }
        let objectToDelete = arrayObjects.filter { (object) -> Bool in
            return object.value(forKey: "id") as? Int == movie.id
        }
        
        guard let objectForDeletion = objectToDelete.first else {
            return (false, "Movie id not matched")
        }
        managedContext?.delete(objectForDeletion)
        do {
            try managedContext?.save()
            return (true, "Deleted")
        } catch {
            print("could not save context after deleting, error: \(error)")
            return (false, error.localizedDescription)
        }
    }
    
    func saveMovieInDB(movie: MovieListItem, for EntityName: String) -> (Bool, String) {
        // 1
        guard let managedContext = self.managedContext else { return (false, "Managed Context is nil")}
            
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: EntityName,
                                       in: managedContext)!
        
        let movieObject = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        movieObject.setValue(movie.id, forKey: "id")
        movieObject.setValue(movie.posterPath, forKey: "posterPath")
        movieObject.setValue(movie.title, forKey: "title")
        movieObject.setValue(movie.releaseDate, forKey: "releaseDate")
        movieObject.setValue(movie.overview, forKey: "overview")
        
        // 4
        do {
            try managedContext.save()
            return (true, "Saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return (false, error.localizedDescription)
        }
    }
}
extension CoreDataManager {
    
    func saveForCache(arrayMovies: [MovieListItem]) {
        if let managedObjects = fetchArrayOfManagedObjects(for: entityNameMovies) {
            managedObjects.forEach({ managedContext?.delete( $0 )})
            
            do      { try managedContext?.save(); print("Deleted existing cache data") }
            catch   { print("could not delete managed objects, error: \(error)") }
                
        }
        
        arrayMovies.forEach({
            let (saved, message ) = saveMovieInDB(movie: $0, for: entityNameMovies)
            print("in \(#function), saved: \(saved), message: \(message)")
        })
    }
    
    func getArrayOfMovies(entityName: String) -> (Bool, [MovieListItem?]?, String? ) {
        guard let managedObjects = fetchArrayOfManagedObjects(for: entityName) else {
            return (false, nil, "managed objects not found")
        }
        let arrayMovies = managedObjects.map { (object) -> MovieListItem? in
            guard let id = object.value(forKey: "id") as? Int,
                let title = object.value(forKey: "title") as? String,
                let posterPath = object.value(forKey: "posterPath") as? String,
                let overview = object.value(forKey: "overview") as? String,
                let releaseData = object.value(forKey: "releaseDate") as? String else {
                    return nil
            }
            let item = MovieListItem.init(id: id, posterPath: posterPath, title: title, releaseDate: releaseData, overview: overview)
            return item
            
        }
        return(true, arrayMovies, "Success" )
    }
}

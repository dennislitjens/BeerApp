//
//  Beer.swift
//  BeerApp
//
//  Created by Dennis Litjens on 2/10/17.
//  Copyright © 2017 Dennis Litjens. All rights reserved.
//

import UIKit
import os.log

class Beer : NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String
    var photo: UIImage? //optional
    var rating: Int
    var descriptionBeer: String
    var alcoholPercentage: Double
    
    //MARK: Archiving Paths
    
   /* static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")*/
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
        static let descriptionBeer = "descriptionBeer"
        static let alcoholPercentage = "alcoholPercentage"
    }
    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int, descriptionBeer: String, alcoholPercentage: Double) {
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0  {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        self.descriptionBeer = descriptionBeer
        self.alcoholPercentage = alcoholPercentage
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }
    
    //required means init must be implemented on every subclass, if the subclass defines its own inits
    required convenience init?(coder aDecoder: NSCoder){
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Beer object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        guard let descriptionBeer = aDecoder.decodeObject(forKey: PropertyKey.descriptionBeer) as? String else {
            os_log("Unable to decode the description for a Beer object.", log: OSLog.default, type: .debug)
            return nil
        }
        let alcoholPercentage = aDecoder.decodeDouble(forKey: PropertyKey.alcoholPercentage)
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating, descriptionBeer: descriptionBeer, alcoholPercentage: alcoholPercentage)
    }
}

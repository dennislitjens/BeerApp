//
//  ViewController.swift
//  BeerApp
//
//  Created by Dennis Litjens on 29/09/17.
//  Copyright © 2017 Dennis Litjens. All rights reserved.
//

import UIKit
import os.log
import CoreData

class ViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var alcoholPercentageLabel: UILabel!
    @IBOutlet weak var addToFavouriteButton: UIButton!
    
    var beer: Beer?
    var savedBeers: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromBeerDataObject()
        if savedBeersContainsDisplayedBeer(){
            addToFavouriteButton.isEnabled = false
            addToFavouriteButton.isUserInteractionEnabled = false
            addToFavouriteButton.alpha = 0.5;
        }
        
          if let beer = beer {
            nameLabel.text = beer.name
            photoImageView.sd_setImage(with: URL(string: beer.photo!), placeholderImage: UIImage(named: "defaultNoImage"))
            ratingControl.rating = beer.rating
            alcoholPercentageLabel.text = String(beer.alcoholPercentage)
            photoImageView.sd_setImage(with: URL(string: beer.photo!), placeholderImage: UIImage(named: "defaultNoImage"))
            descriptionTextField.text = beer.descriptionBeer
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    //MARK: Actions
    @IBAction func addToFavorites(_ sender: UIButton) {
        saveBeer()
        addToFavouriteButton.isEnabled = false
        addToFavouriteButton.isUserInteractionEnabled = false
        addToFavouriteButton.alpha = 0.5;
    }
    
    @IBAction func addToAlcoholCounter(_ sender: UIButton) {
        //Alertmessage: you've drinked the certain beer
        let alertBeerDrinked = UIAlertController(title: "Cheers!", message: "You've drinked this beer.", preferredStyle: .alert)
        alertBeerDrinked.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertBeerDrinked, animated: true, completion: nil)
    }
    
    //MARK: Private functions
    private func saveBeer(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "BeerObject",
                                       in: managedContext)!
        let beerFromManagedObject = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        beerFromManagedObject.setValue(beer?.name, forKeyPath: "name")
        beerFromManagedObject.setValue(beer?.photo, forKeyPath: "photo")
        beerFromManagedObject.setValue(beer?.rating, forKeyPath: "rating")
        beerFromManagedObject.setValue(beer?.descriptionBeer, forKeyPath: "descriptionBeer")
        beerFromManagedObject.setValue(beer?.alcoholPercentage, forKeyPath: "alcoholPercentage")
        
        do {
            try managedContext.save()
            savedBeers.append(beerFromManagedObject)
            print("gel")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func savedBeersContainsDisplayedBeer() -> Bool {
        print(String(savedBeers.count) + "  count")
        if let unwrappedName = beer?.name {
            for savedBeer in savedBeers {
                if savedBeer.value(forKeyPath: "name") as? String == unwrappedName {
                    return true
                }
            }
        }
        return false
    }
    
    private func getDataFromBeerDataObject(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "BeerObject")
        
        do {
            savedBeers = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

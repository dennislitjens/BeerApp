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
import Alamofire
import SwiftyJSON

class BeerViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var addToFavouriteButton: UIButton!
    @IBOutlet weak var addToCounterButton: UIButton!
    
    //MARK: Properties
    var beer: Beer?
    var savedBeers: [NSManagedObject] = []
    var beerUnits: Double = 0.0
    var firstBeerTime: Date = Date()
    var weight: Double = 0
    var bodyfluid: Double = 0
    var firstBeerTimeSet: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional layout setup
        self.hideKeyboardWhenTappedAround()
        addToFavouriteButton.layer.cornerRadius = 20
        addToFavouriteButton.clipsToBounds = true
        addToCounterButton.layer.cornerRadius = 20
        addToCounterButton.clipsToBounds = true
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 0
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        
        getSavedProfileData()
        getDataFromBeerDataObject()
        if savedBeersContainsDisplayedBeer(){
            addToFavouriteButton.isEnabled = false
            addToFavouriteButton.isUserInteractionEnabled = false
            addToFavouriteButton.alpha = 0.5;
        }
        
          if let beer = beer {
            nameLabel.text = beer.name + ": " +  String(beer.alcoholPercentage) + " %"
            photoImageView.sd_setImage(with: URL(string: beer.photo!), placeholderImage: UIImage(named: "defaultNoImage"))
            photoImageView.sd_setImage(with: URL(string: beer.photo!), placeholderImage: UIImage(named: "defaultNoImage"))
            descriptionTextField.text = beer.descriptionBeer
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismissKeyboard()
    }
    
    //MARK: Actions
    @IBAction func addToFavorites(_ sender: UIButton) {
        saveBeer()
        addToFavouriteButton.isEnabled = false
        addToFavouriteButton.isUserInteractionEnabled = false
        addToFavouriteButton.alpha = 0.5;
    }
    
    @IBAction func addToAlcoholCounter(_ sender: UIButton) {
        let driveAgainService = DriveAgainService(viewController: self, weight: self.weight, bodyfluid: self.bodyfluid, beerUnits: self.beerUnits, firstBeerDateTime: self.firstBeerTime)

        if weight == 0 || bodyfluid == 0{
            alertProfileNeedsToBeEditedForCalculation()
        }else{
            storeBeerToAlcholCounter()
            
            if driveAgainService.calculateBloodAlcoholPercentage() >= 0.5 {
                let secondsToDrivingAgain = driveAgainService.calculateSecondsToDrivingAgain()
                print("seconds ", secondsToDrivingAgain)
                driveAgainService.scheduleNotificationForDrivingAgain(timeInterval: secondsToDrivingAgain)
            }
            alertAddedToAlcoholCounter()
        }
    }
    
    //MARK: Private functions
    
    private func storeBeerToAlcholCounter(){
        let defaults = UserDefaults.standard
        
        if beer?.alcoholPercentage != nil{
            if !firstBeerTimeSet {
                defaults.set(Date(), forKey: "firstbeer")
            }
            var beerUnitsFromOneBeer = (beer?.alcoholPercentage)! / 5
            self.beerUnits += beerUnitsFromOneBeer
            defaults.set(self.beerUnits, forKey: "beerunits")
        }else{
            alertNoAlcoholPercentageToCalculateWith()
        }
    }
    
    private func alertAddedToAlcoholCounter(){
        let alertBeerDrinked = UIAlertController(title: "Cheers!", message: "You've drinked this beer.", preferredStyle: .alert)
        alertBeerDrinked.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertBeerDrinked, animated: true, completion: nil)
    }
    
    private func alertNoAlcoholPercentageToCalculateWith(){
        let alertNoAlcoholPercentage = UIAlertController(title: "Oops!", message: "There isn't a alcohol percentage to calculate with", preferredStyle: .alert)
        alertNoAlcoholPercentage.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertNoAlcoholPercentage, animated: true, completion: nil)
    }
    
    private func alertProfileNeedsToBeEditedForCalculation(){
        let alertEditProfile = UIAlertController(title: "Oops!", message: "You have to edit you profile first before we can calculate if you can drive.", preferredStyle: .alert)
        alertEditProfile.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertEditProfile, animated: true, completion: nil)
    }
    
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
    
    private func getRandomBeer(){
        Alamofire.request("http://api.brewerydb.com/v2/beer/random?key=ea3f42048aa2b2e591a2be6861ca2f26").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let jsonStringResponseData = JSON(responseData.result.value!)
                
                self.beer?.name = jsonStringResponseData["data"]["name"].string!
                self.beer?.descriptionBeer = jsonStringResponseData["data"]["description"].string!
                self.beer?.alcoholPercentage = jsonStringResponseData["data"]["abv"].double!
                self.beer?.photo = jsonStringResponseData["data"]["labels"]["medium"].string
                self.beer?.rating = 0
            }
        }
    }
    
    private func somethingWentWrongMessage(){
        let alertNoBeersFound = UIAlertController(title: "Oops!", message: "Something went wrong with getting random beer", preferredStyle: .alert)
        alertNoBeersFound.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertNoBeersFound, animated: true, completion: nil)
    }
    
    private func getSavedProfileData(){
        let defaults = UserDefaults.standard
        if let weightFromUserDefaults = defaults.object(forKey: "weight"){
            self.weight = weightFromUserDefaults as! Double
        } else {
            self.weight = 0
        }
        if let bodyfluidFromUserDefaults = defaults.object(forKey: "bodyfluid"){
            self.bodyfluid = bodyfluidFromUserDefaults as! Double
        } else {
            self.bodyfluid = 0
        }
        if let beerUnitsFromUserDefaults = defaults.object(forKey: "beerunits"){
            self.beerUnits = beerUnitsFromUserDefaults as! Double
        } else {
            self.beerUnits = 0
        }
        if let firstBeerTimeFromUserDefaults = defaults.object(forKey: "firstbeer"){
            self.firstBeerTime = firstBeerTimeFromUserDefaults as! Date
            firstBeerTimeSet = true
        }
    }
    
    private func checkIfDrinkedTooMuch(driveAgainService: DriveAgainService) -> Bool{
        let bloodAlcoholPercentage = driveAgainService.calculateBloodAlcoholPercentage()
        if bloodAlcoholPercentage >= 0.5{
            return true
        }else{
            return false
        }
    }
}

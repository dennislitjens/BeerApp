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

class CanIDriveController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var stillDriveLabel: UILabel!
    
    
    //MARK: Properties
    var weight: Double = 0
    var bodyfluid: Double = 0
    var beerUnits: Double = 0
    var firstBeerDateTime: Date = Date()
    var firstBeerTimeIsSet: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSavedProfileData()
        if weight == 0 || bodyfluid == 0{
            stillDriveLabel.text = "Edit profile first"
        }else{
            stillDriveLabel.text = "Yes you can!"
        }
        let driveAgainService = DriveAgainService(viewController: self, weight: weight, bodyfluid: bodyfluid, beerUnits: beerUnits, firstBeerDateTime: firstBeerDateTime)
        let bloodAlcoholPercentage = driveAgainService.calculateBloodAlcoholPercentage()
        if bloodAlcoholPercentage >= 0.5 {
            stillDriveLabel.text = "No you can't!"
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    //MARK: Actions
    @IBAction func resetAlcoholCounter(_ sender: UIButton) {
        self.beerUnits = 0
        firstBeerTimeIsSet = false
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "beerunits")
        defaults.removeObject(forKey: "firstbeer")
        
        stillDriveLabel.text = "Yes you can!"
    }
    
    //MARK: Private functions
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
            self.firstBeerDateTime = firstBeerTimeFromUserDefaults as! Date
        } else {
            firstBeerTimeIsSet = false
        }
    }
}


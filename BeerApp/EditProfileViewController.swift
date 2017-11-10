//
//  EditProfileViewController.swift
//  BeerApp
//
//  Created by Dennis Litjens on 26/10/17.
//  Copyright © 2017 Dennis Litjens. All rights reserved.
//

import UIKit
import DLRadioButton

class EditProfileViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var genderRadioButton: DLRadioButton!
    @IBOutlet weak var womanRadioButton: DLRadioButton!
    @IBOutlet weak var manRadioButton: DLRadioButton!
    @IBOutlet weak var editProfileButton: UIButton!
    
    //MARK: Properties
    var weight: Double = 0
    var bodyfluid: Double = 0
    var beerUnits: Double = 0
    var firstBeerTime: Date = Date()
    
    override func viewDidLoad() {
        editProfileButton.layer.cornerRadius = 20
        editProfileButton.clipsToBounds = true
        self.hideKeyboardWhenTappedAround()
        self.dismissKeyboard()
        super.viewDidLoad()
        getProfileData()

        if self.bodyfluid == 0.61 {
            womanRadioButton.isSelected = true
        }else{
            manRadioButton.isSelected = true
        }
        weightTextField.text = String(self.weight)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismissKeyboard()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Actions
    @IBAction func saveEditedProfile(_ sender: UIButton) {
        var weightFromTextBox = weightTextField.text
        if Double(weightFromTextBox!) != nil {
            let bodyfluid = getBodyFluid()
            let weight = Double(weightFromTextBox!)
            saveProfileDataAsUserDefaults(bodyfluid: bodyfluid, weight: weight!)
            
            if(beerUnits != 0){
                setNewNotification()
            }
            
            _ = navigationController?.popViewController(animated: true)
        }else{
            showInvalidWeightInput()
        }
    
    }
    
    //MARK: Private methods
    private func getProfileData(){
        let defaults = UserDefaults.standard
        self.weight = defaults.double(forKey: "weight")
        self.bodyfluid = defaults.double(forKey: "bodyfluid")
        self.beerUnits = defaults.double(forKey: "beerunits")
        print(defaults.object(forKey: "firstbeer"))
        if beerUnits == 0{
            return
        }else{
            self.firstBeerTime = defaults.object(forKey: "firstbeer") as! Date
        }
    }
    
    private func showInvalidWeightInput(){
        let alertInvalidWeight = UIAlertController(title: "Oops!", message: "Invalid weight input", preferredStyle: .alert)
        alertInvalidWeight.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertInvalidWeight, animated: true, completion: nil)
    }
    
    private func saveProfileDataAsUserDefaults(bodyfluid: Double, weight: Double){
        let defaults = UserDefaults.standard
        defaults.set(bodyfluid, forKey: "bodyfluid")
        defaults.set(weight, forKey: "weight")
    }
    
    private func getBodyFluid() -> Double{
        if manRadioButton.isSelected{
            return 0.72
        }else{
            return 0.61
        }
    }
    
    private func setNewNotification(){
        let driveAgainService = DriveAgainService(viewController: self, weight: self.weight, bodyfluid: self.bodyfluid, beerUnits: self.beerUnits, firstBeerDateTime: self.firstBeerTime)
        
            if driveAgainService.calculateBloodAlcoholPercentage() >= 0.5 {
                let secondsToDrivingAgain = driveAgainService.calculateSecondsToDrivingAgain()
                print("seconds ", secondsToDrivingAgain)
                driveAgainService.scheduleNotificationForDrivingAgain(timeInterval: secondsToDrivingAgain)
            }
        
    }
}

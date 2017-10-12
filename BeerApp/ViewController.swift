//
//  ViewController.swift
//  BeerApp
//
//  Created by Dennis Litjens on 29/09/17.
//  Copyright © 2017 Dennis Litjens. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var alcoholPercentageLabel: UILabel!
    var beer: Beer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
          if let beer = beer {
            nameLabel.text = beer.name
            photoImageView.image = beer.photo
            ratingControl.rating = beer.rating
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    //MARK: Actions
    @IBAction func addToFavorites(_ sender: UIButton) {
    }
    
    @IBAction func addToAlcoholCounter(_ sender: UIButton) {
        //Alertmessage: you've drinked the certain beer
        let alertBeerDrinked = UIAlertController(title: "Cheers!", message: "You've drinked this beer.", preferredStyle: .alert)
        alertBeerDrinked.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertBeerDrinked, animated: true, completion: nil)
    }
    
}

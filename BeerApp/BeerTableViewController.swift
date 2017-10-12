//
//  BeerTableViewController.swift
//  BeerApp
//
//  Created by Dennis Litjens on 2/10/17.
//  Copyright © 2017 Dennis Litjens. All rights reserved.
//

import UIKit
import os.log

class BeerTableViewController: UITableViewController {

    //MARK: Properties
    
    var beers = [Beer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(BeerTableViewCell.self, forCellReuseIdentifier: "cell")
            //Load the sample data.
            loadSampleBeers()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BeerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BeerTableViewCell else{
            fatalError("The dequeued cell is not an instance of BeerTableViewCell.")
        }//request a cell from table view
        
        // Fetches the appropriate meal for the data source layout.
        let beer = beers[indexPath.row]
        
        // Configure the cell
        cell.nameLabel.text = beer.name
        cell.photoImageView.image = beer.photo
        cell.ratingControl.rating = beer.rating
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
    
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
        // Delete the row from the data source
        beers.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        }
     }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
            
            guard let beerDetailViewController = segue.destination as? ViewController else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedBeerCell = sender as? BeerTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedBeerCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedBeer = beers[indexPath.row]
            beerDetailViewController.beer = selectedBeer
            
    }
    
    //MARK: Actions
    
    /*@IBAction func unwindToMealList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as?
            ViewController, let meal = sourceViewController.meal{
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                // Update an existing meal.
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }else{
                // Add a new meal
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Save the meals
            saveMeals()
        }
    }*/
    
    //MARK: Private Methods
    
    private func loadSampleBeers() {
        let photo1 = UIImage(named: "beer1")
        let photo2 = UIImage(named: "beer2")
        let photo3 = UIImage(named: "beer3")
        os_log("hall", log: OSLog.default, type: .debug)
        
        guard let beer1 = Beer(name: "Duvel", photo: photo1, rating: 4, descriptionBeer: "Duvel is a natural beer with a subtle bitterness, a refined flavour and a distinctive hop character. The unique brewing process, which takes about 90 days, guarantees a pure character, delicate effervescence and a pleasant sweet taste of alcohol.", alcoholPercentage: 8.5) else {
            fatalError("Unable to instantiate beer1")
        }
        
        guard let beer2 = Beer(name: "Leffe", photo: photo2, rating: 5, descriptionBeer: "Leffe Blond is an authentic blond abbey beer with a slight hint of bitterness to it.", alcoholPercentage: 6.6) else {
            fatalError("Unable to instantiate beer2")
        }
        
        guard let beer3 = Beer(name: "Jupiler", photo: photo3, rating: 3, descriptionBeer: "Jupiler is the most famous and most popular beer in Belgium. This delicious lager is brewed with the finest ingredients (malt, maize, water, hop, yeast), using undisputed craftsmanship, ensuring an outstanding beer quality. Jupiler offers refreshment on a wide variety of occasions, thanks to its digestibility and accessible taste. Jupiler (5,2 % ABV) is ideally served at a temperature of 3Ã?Â°C. The low-alcoholic variant Jupiler N.A. (0.5%) should be served at 1-2Ã?Â°C.", alcoholPercentage: 5.2) else {
            fatalError("Unable to instantiate beer3")
        }
        
        beers += [beer1, beer2, beer3]
    }
    
    
    /*private func loadBeers() -> [Beer]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Beer.ArchiveURL.path) as? [Beer]
    }*/

}

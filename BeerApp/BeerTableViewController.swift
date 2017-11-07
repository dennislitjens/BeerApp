//
//  BeerTableViewController.swift
//  BeerApp
//
//  Created by Dennis Litjens on 2/10/17.
//  Copyright © 2017 Dennis Litjens. All rights reserved.
//

import UIKit
import os.log
import Alamofire
import SwiftyJSON
import SDWebImage
import CoreData

class BeerTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    //MARK: Outlets
    @IBOutlet var beerTableView: UITableView!
    
    //MARK: Properties

    let persistentContainer = NSPersistentContainer(name: "BeerApp")
    var beers = [Beer]()
    var beersToDelete = [Beer]()
    var searchText = ""
    var savedBeers: [NSManagedObject] = []
    var senderFromSegue: String = ""
    var isSenderFromSequeSearch: Bool = true
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<BeerObject> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<BeerObject> = BeerObject.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(BeerTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.allowsMultipleSelectionDuringEditing = true;
        DispatchQueue.global(qos: .userInitiated).async {
            if self.senderFromSegue == "searchSegue"{
                self.title = "Search results: " + self.searchText
                self.getSearchedBeers(searchText: self.searchText)
            }else if self.senderFromSegue == "favouriteSegue"{
                self.navigationItem.rightBarButtonItem = self.editButtonItem;
                self.isSenderFromSequeSearch = false
                self.title = "Favourite beers"
                self.getFetchedBeerObjects()
            }
        }
        
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
        if isSenderFromSequeSearch{
            return beers.count
        }else{
            guard let beersFromDataObjects = fetchedResultsController.fetchedObjects else {
                return 0
            }
            return beersFromDataObjects.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BeerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BeerTableViewCell else{
            fatalError("The dequeued cell is not an instance of BeerTableViewCell.")
        }//request a cell from table view
        
        /*guard let beer = self.fetchedResultsController?.object(at: indexPath) as! Beer? else {
            fatalError("Attempt to configure cell without a managed object")
        }*/
        
        // Fetches the appropriate beer for the data source layout.
        if isSenderFromSequeSearch{
            let beer = beers[indexPath.row]
            cell.nameLabel.text = beer.name
            cell.photoImageView.sd_setImage(with: URL(string: beer.photo!), placeholderImage: UIImage(named: "defaultNoImage"))
            cell.alcoholPercentageLabel.text = String(beer.alcoholPercentage) + " %"
        }else{
            let beer = fetchedResultsController.object(at: indexPath)
            cell.nameLabel.text = beer.name
            cell.photoImageView.sd_setImage(with: URL(string: beer.photo!), placeholderImage: UIImage(named: "defaultNoImage"))
            cell.alcoholPercentageLabel.text = String(beer.alcoholPercentage) + " %"
        }
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
        beers.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        }
     }
    
   override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.init(rawValue: 3)!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        super.prepare(for: segue, sender: sender)
        if let destinationSegue = segue.destination as? BeerViewController {
            guard let beerDetailViewController = segue.destination as? BeerViewController else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedBeerCell = sender as? BeerTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedBeerCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            if isSenderFromSequeSearch{
                let selectedBeer = beers[indexPath.row]
                beerDetailViewController.beer = selectedBeer
            }else{
                let selectedBeer = fetchedResultsController.object(at: indexPath)
                beerDetailViewController.beer = convertBeerObjectToBeer(beerObject: selectedBeer)
            }
        }
    }
    
    //MARK: Actions
    
    
    @IBAction func didTapBringCheckBoxBtn(_ sender: UIBarButtonItem) {
    }
    
    
    //MARK: Private Methods
    private func getFetchedBeerObjects(){
        self.persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
                
            } else {
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                self.beerTableView.reloadData()
            }
        }
    }
    
    private func convertBeerObjectToBeer(beerObject: BeerObject) -> Beer{
        let name = beerObject.name
        let description = beerObject.descriptionBeer
        let alcoholPercentage = beerObject.alcoholPercentage
        let photoUrl = beerObject.photo
        let rating = beerObject.rating
        
        let convertedBeer = Beer(name: name!, photo: photoUrl!, rating: rating, descriptionBeer: description!, alcoholPercentage: alcoholPercentage)
        return convertedBeer!
    }
    
    private func showNoBeersFoundMessage(){
        let alertNoBeersFound = UIAlertController(title: "Oops!", message: "No beers found", preferredStyle: .alert)
        alertNoBeersFound.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertNoBeersFound, animated: true, completion: nil)
    }
    
    private func getSearchedBeers(searchText: String){
        var arrayNames = [String]()
        var arrayDescriptions = [String]()
        var arrayImageUrls = [String]()
        var arrayAlcoholPercentages = [Double]()
        
        Alamofire.request("http://api.brewerydb.com/v2/search?q=" + searchText + "&type=beer&key=ea3f42048aa2b2e591a2be6861ca2f26").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let jsonStringResponseData = JSON(responseData.result.value!)
                arrayNames =  jsonStringResponseData["data"].arrayValue.map({$0["name"].stringValue})
                arrayDescriptions =  jsonStringResponseData["data"].arrayValue.map({$0["description"].stringValue})
                arrayImageUrls = jsonStringResponseData["data"].arrayValue.map({$0["labels"]["medium"].stringValue})
                print(arrayImageUrls)
                arrayAlcoholPercentages =  jsonStringResponseData["data"].arrayValue.map({$0["abv"].doubleValue})
                
                if arrayNames.count != 0 {
                    for i in 0...(arrayNames.count - 1)  {
                        let beerName = arrayNames[i]
                        let beerDescription = arrayDescriptions[i]
                        let beerAlcoholPercentage = arrayAlcoholPercentages[i]
                        let imageUrl = arrayImageUrls[i]
                        
                        guard let beer = Beer(name: beerName, photo: imageUrl, rating: 3, descriptionBeer: beerDescription, alcoholPercentage: beerAlcoholPercentage ) else {
                            fatalError("Unable to instantiate beer")
                        }
                        
                        self.beers += [beer]
                        
                    }
                }else{
                    self.showNoBeersFoundMessage()
                }
                self.beerTableView.reloadData()
        }
        }
    }
}

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
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    //MARK: Properties

    let persistentContainer = NSPersistentContainer(name: "BeerApp")
    var beers = [Beer]()
    var beersToDeleteIndexes = [Int]()
    var searchText = ""
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
        
            if self.senderFromSegue == "searchSegue"{
                self.title = "Search results: " + self.searchText
                let downloadGroup = DispatchGroup()
                downloadGroup.enter()
                self.getSearchedBeers(searchText: self.searchText, downloadGroup: downloadGroup)
                DispatchQueue.global(qos: .background).async {
                    downloadGroup.wait()
                    DispatchQueue.main.async {
                        self.beerTableView.reloadData()
                    }
                }
            }else if self.senderFromSegue == "favouriteSegue"{
                self.navigationItem.rightBarButtonItem = self.editButtonItem;
                self.isSenderFromSequeSearch = false
                self.title = "Favourite beers"
                self.getFetchedBeerObjects()
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
    
    override func viewDidAppear(_ animated: Bool) {
        if self.senderFromSegue == "favouriteSegue"{
            self.navigationController?.setToolbarHidden(false, animated: false)
            var toolBarItems = [UIBarButtonItem]()
            var deleteBeerButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedBeers(_:)))
            toolBarItems.append(deleteBeerButton)
            self.navigationController?.toolbar.items = toolBarItems
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
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
            cell.photoImageView.sd_setImage(with: URL(string: beer.photo!), placeholderImage: UIImage(named: "defaultNoImage"))
            cell.nameLabel.text = beer.name
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
        if isSenderFromSequeSearch{
            return false
        }else{
            return true
        }
     }
    
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let beerToDelete = fetchedResultsController.object(at: indexPath)
            beerToDelete.managedObjectContext?.delete(beerToDelete)
            do {
                try persistentContainer.viewContext.save()
                guard let beersFromDataObjects = fetchedResultsController.fetchedObjects else {
                        return
                    }
                if beersFromDataObjects.count == 0{
                    showNoFavouriteBeersAlert()
                }
            } catch {
                print("\(error), \(error.localizedDescription)")
            }
        }
     }
    
   override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        //return UITableViewCellEditingStyle.init(rawValue: 3)!
        return .delete
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath){
        beersToDeleteIndexes.append(indexPath.row)
        
    }
    
    override func tableView(_ tableView: UITableView,
                            didDeselectRowAt indexPath: IndexPath){
        let indexOfDeselectedBeer = beersToDeleteIndexes.index(of: indexPath.row)
        print("azd")
        beersToDeleteIndexes.remove(at: indexOfDeselectedBeer!)
        /*for i in 0..<beersToDeleteIndexes.count{
            if beersToDeleteIndexes[i] == indexPath.row{
                beersToDeleteIndexes.remove(at: i)
            }
        }*/
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "detailSegue"{
            return !self.isEditing
        }else{
            return true
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                print(indexPath)
                self.beerTableView.beginUpdates()
                self.beerTableView.deleteRows(at: [indexPath], with: .automatic)
                self.beerTableView.endUpdates()
            }
            break;
        default:
            print("Something went wrong, wrong editingtype selected")
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
    @IBAction func deleteSelectedBeers(_ sender: Any) {
        if beersToDeleteIndexes.count != 0{
            for i in 0..<beersToDeleteIndexes.count {
                let beerToDelete = fetchedResultsController.object(at: IndexPath(row: beersToDeleteIndexes[i]-i, section: 0))
                beerToDelete.managedObjectContext?.delete(beerToDelete)
                do {
                    try persistentContainer.viewContext.save()
                    guard let beersFromDataObjects = fetchedResultsController.fetchedObjects else {
                        return
                    }
                    if beersFromDataObjects.count == 0{
                        showNoFavouriteBeersAlert()
                    }
                } catch {
                    print("\(error), \(error.localizedDescription)")
                }
            }
            beersToDeleteIndexes.removeAll()
        }
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
                    guard let beersFromDataObjects = self.fetchedResultsController.fetchedObjects else {
                        return
                    }
                    if beersFromDataObjects.count == 0{
                        self.showNoFavouriteBeersAlert()
                    }
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
        let action = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertNoBeersFound.addAction(action)
        present(alertNoBeersFound, animated: true, completion: nil)
    }
    
    private func showNoFavouriteBeersAlert(){
        let alertNoFavouriteBeers = UIAlertController(title: "Oops!", message: "You have no favourite beers", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertNoFavouriteBeers.addAction(action)
        present(alertNoFavouriteBeers, animated: true, completion: nil)
    }
    
    private func getSearchedBeers(searchText: String, downloadGroup: DispatchGroup){
        var arrayNames = [String]()
        var arrayDescriptions = [String]()
        var arrayImageUrls = [String]()
        var arrayAlcoholPercentages = [Double]()
        
        Alamofire.request("http://api.brewerydb.com/v2/search?q=" + searchText + "&type=beer&key=ea3f42048aa2b2e591a2be6861ca2f26").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let jsonStringResponseData = JSON(responseData.result.value!)
                print(jsonStringResponseData)
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
                    downloadGroup.leave()
                }else{
                    self.showNoBeersFoundMessage()
                }
        }
        }
    }
}

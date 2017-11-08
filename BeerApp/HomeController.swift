import UIKit
import os.log

class HomeController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "driveSegue" && segue.identifier != "randomSegue"{
            if sender is String {
                let navigationController = segue.destination as! UINavigationController
                
                let beerTableViewController = navigationController.viewControllers.first as! BeerTableViewController
                
                beerTableViewController.searchText = searchBar.text!
                beerTableViewController.senderFromSegue = "searchSegue"
            }else{
                let navigationController = segue.destination as! UINavigationController
                let beerTableViewController = navigationController.viewControllers.first as! BeerTableViewController
                
                beerTableViewController.senderFromSegue = "favouriteSegue"
            }
        }
        
    }
    
    //MARK: Actions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            performSegue(withIdentifier: "beerTableSegue", sender: searchText)
        }
    }
}

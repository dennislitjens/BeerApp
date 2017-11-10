import UIKit
import os.log

class HomeController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var favouriteBeersButton: UIButton!
    @IBOutlet weak var luckyGuessButton: UIButton!
    @IBOutlet weak var stillDriveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.dismissKeyboard()
        self.hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        favouriteBeersButton.layer.cornerRadius = 20
        favouriteBeersButton.clipsToBounds = true
        luckyGuessButton.layer.cornerRadius = 20
        luckyGuessButton.clipsToBounds = true
        stillDriveButton.layer.cornerRadius = 20
        stillDriveButton.clipsToBounds = true
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "driveSegue" && segue.identifier != "randomSegue"{
            if sender is String {
                let navigationController = segue.destination as! UIViewController
                
                let beerTableViewController = navigationController as! BeerTableViewController
                
                beerTableViewController.searchText = searchBar.text!
                beerTableViewController.senderFromSegue = "searchSegue"
            }else{
                let navigationController = segue.destination as! UIViewController
                let beerTableViewController = navigationController as! BeerTableViewController
                
                beerTableViewController.senderFromSegue = "favouriteSegue"
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismissKeyboard()
    }
    
    //MARK: Actions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            performSegue(withIdentifier: "beerTableSegue", sender: searchText)
        }
    }
    
    
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//
//  HomeViewController.swift
//  MTWeatherApp
//
//  Created by Dhaval on 3/19/17.
//  Copyright © 2017 Dhaval. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate  {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    var arrayFiltered : [Any] = []
    var arrayLocation : [Any] = []
    
    // MARK:- View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCity()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
     // MARK:- Data Load Methods

    func managedObjectContext() -> NSManagedObjectContext
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 10.0, *) {
            return appDelegate.persistentContainer.viewContext
        } else {
            return appDelegate.managedObjectContext
        }
    }
    
    func loadCity()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName:"City", in: self.managedObjectContext())
        
        fetchRequest.entity = entityDescription
        do {
            let result = try self.managedObjectContext().fetch(fetchRequest)
            if (result.count > 0) {
                arrayLocation = result
                arrayFiltered = arrayLocation
                tblView.reloadData()
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

     // MARK:- Tableview Delegate & DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CityTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as! CityTableViewCell
        
        if let city: City = arrayFiltered[indexPath.row] as? City {
            cell.lblCity?.text = city.name as String?
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "CityDetailViewController") as! CityDetailViewController
        vc.selectedCity = arrayFiltered[indexPath.row] as! City
        self.navigationController?.show(vc, sender: self)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if !searchBar.isFirstResponder{
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
       
        switch editingStyle {
        case .delete:
            // remove the deleted item from the model
            self.managedObjectContext().delete(arrayFiltered[indexPath.row] as! NSManagedObject )
            arrayFiltered.remove(at: indexPath.row)
            do {
                try self.managedObjectContext().save()
            }
            catch {
                let deleteError = error as NSError
                print(deleteError)
                
                let alert = UIAlertController(title: "Error", message: "Fail to remove, try again", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            return
        }
    }
    
     // MARK:- SearchBar Delegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        arrayFiltered = arrayLocation.filter({ (city) -> Bool in
            let tmp: NSString = NSString(string:(city as! City).name!)
            let range = tmp.range(of: searchText, options: .caseInsensitive)
            return range.location != NSNotFound
        })
        
        if(searchText.characters.count == 0){
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            arrayFiltered = arrayLocation
        }
        tblView.reloadData()
    }

}


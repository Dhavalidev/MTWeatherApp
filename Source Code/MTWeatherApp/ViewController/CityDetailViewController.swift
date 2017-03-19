//
//  CityDetailViewController.swift
//  MTWeatherApp
//
//  Created by Dhaval on 3/19/17.
//  Copyright © 2017 Dhaval. All rights reserved.
//

import UIKit

class CityDetailViewController: UIViewController {
    
    
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblHumidity: UILabel!
    @IBOutlet weak var lblRain: UILabel!
    @IBOutlet weak var lblWind: UILabel!
    
    public var selectedCity : City = City()
    private var cityDetail : CityDetail?
    
    // MARK:- View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- Custom Methods

    func getWeatherData() -> Void {
        NetworkManager.sharedManager.showActivityIndicator(uiView: self.view)
        NetworkManager.sharedManager.getWeather(city: selectedCity) { (response, error) in
            
            NetworkManager.sharedManager.hideActivityIndicator(uiView: self.view)

            guard error != nil else {
                self.cityDetail = response
                self.displayData()
                return
            }
            
            let alert = UIAlertController(title: nil, message: error, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (action) in
                DispatchQueue.main.async {
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    func displayData() {
        DispatchQueue.main.async {
            
            if let details = self.cityDetail{
            
            self.lblCity.text = self.selectedCity.name
            self.lblTemp.text = "\(details.tempMin)° / \(details.tempMax)° C"
            self.lblHumidity.text = "\(details.humidity) %"
            self.lblRain.text = "\(details.rain) %"
            self.lblWind.text = "\(details.windSpeed) m/s"
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}


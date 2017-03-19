//
//  NetworkManager.swift
//  MTWeatherApp
//
//  Created by Dhaval on 3/19/17.
//  Copyright © 2017 Dhaval. All rights reserved.
//

import UIKit

class NetworkManager {
    
    // Shared Instance
    static let sharedManager = NetworkManager()
    
    // private variable declaration
    private var container: UIView = UIView()
    private var loadingView: UIView = UIView()
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "c6e381d8c7ff98f0fee43775817cf6ad"
    private let unit = "metric"
    
    
    // MARK:- Weather API Call
    func getWeather(city: City, complition:@escaping (CityDetail, String?)->Void) {
        
        let session = URLSession.shared
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?lat=\(city.lat)&lon=\(city.long)&appid=\(openWeatherMapAPIKey)&units=\(unit)")!
        let dataTask = session.dataTask(with: weatherRequestURL) { (data, response, error) in
            guard let responseData = data else {
                print("Error: did not receive data")
                complition(CityDetail(), error?.localizedDescription)
                return
            }
            do {
                guard let result = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    complition(CityDetail(), "error trying to convert data to JSON")
                    return
                }
                print("The todo is: " + result.description)
                
                let cityDetail : CityDetail = CityDetail()
                
                if let name = result["name"] as? String {
                    cityDetail.name = name 
                }
                
                if let main = result["main"] as? [String: AnyObject] {
                    if let temp = main["temp"] as? Double {
                        cityDetail.temp = temp
                    }
                    if let tempMin = main["temp_min"] as? Double {
                        cityDetail.tempMin = tempMin
                    }
                    if let tempMax = main["temp_max"] as? Double {
                        cityDetail.tempMax = tempMax
                    }
                    if let humidity = main["humidity"] as? Double {
                        cityDetail.humidity = humidity
                    }
                }
                
                if let clouds = result["clouds"] as? [String: AnyObject] {
                    if let rain = clouds["all"] as? Double {
                    cityDetail.rain = rain
                    }
                }

                if let wind = result["wind"] as? [String: AnyObject] {
                    if let speed = wind["speed"] as? Double {
                        cityDetail.windSpeed = speed
                    }
                    if let direction = wind["deg"] as? Double {
                        cityDetail.windDirection = direction
                    }
                }
                complition(cityDetail,nil)
            } catch  {
                print("error trying to convert data to JSON")
                complition(CityDetail(), "error trying to convert data to JSON")
            }
        }
        dataTask.resume()
    }
    
    // MARK:- Custom Network Indicator

    func showActivityIndicator(uiView: UIView) {
        DispatchQueue.main.async {
            
            self.container.frame = uiView.frame
            self.container.center = uiView.center
            self.container.backgroundColor = self.UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
            
            self.loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            self.loadingView.center = uiView.center
            self.loadingView.backgroundColor = self.UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.activityIndicator.center = CGPoint(x:self.loadingView.frame.size.width / 2, y:self.loadingView.frame.size.height / 2);
            
            self.loadingView.addSubview(self.activityIndicator)
            self.container.addSubview(self.loadingView)
            uiView.addSubview(self.container)
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideActivityIndicator(uiView: UIView) {
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            self.container.removeFromSuperview()
        }
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}

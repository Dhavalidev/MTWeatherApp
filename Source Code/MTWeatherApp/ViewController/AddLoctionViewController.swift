//
//  AddLoctionViewController.swift
//  MTWeatherApp
//
//  Created by Dhaval on 3/19/17.
//  Copyright © 2017 Dhaval. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AddLoctionViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    let newPin = MKPointAnnotation()

     // MARK:- View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK:- MapView Delegate Methods

    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        
        mapView.removeAnnotation(newPin)
        let location = userLocation.location
        
        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        //set region on the map
        mapView.setRegion(region, animated: true)
        
        newPin.coordinate = (location?.coordinate)!
        newPin.title = "Add Location"

        mapView.addAnnotation(newPin)
        
    }
  
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView?.isDraggable = true
            if #available(iOS 9.0, *) {
                pinView?.pinTintColor = .purple
            } else {
                pinView?.pinColor = .purple
            }
            
            let rightButton: AnyObject! = UIButton(type: UIButtonType.contactAdd)
            pinView?.rightCalloutAccessoryView = rightButton as? UIView
        }
        else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(#function)
        if control == view.rightCalloutAccessoryView {
            if let location : CLLocationCoordinate2D = (view.annotation?.coordinate)
            {
                getCityName(loc:location , completionHandler: { (cityName) in
                    
                    let city = NSEntityDescription.insertNewObject(forEntityName: "City", into: self.managedObjectContext()) as! City
                    city.name = cityName
                    city.lat = location.latitude
                    city.long = location.longitude
                    
                    do {
                        try self.managedObjectContext().save()
                        self.dismiss(animated: true, completion: nil)
                    } catch {
                        let saveError = error as NSError
                        print(saveError)
                        
                        let alert = UIAlertController(title: "Error", message: "Please try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.ending {
            let droppedAt = view.annotation?.coordinate
            print(droppedAt ?? "0")
        }
    }
    
    // MARK:- Custom Data Opration Methods

    // Fetch revese Geocoding data && save to core data
    func getCityName(loc : CLLocationCoordinate2D, completionHandler:@escaping (String) -> Void) -> Void {
        
         NetworkManager.sharedManager.showActivityIndicator(uiView: self.view)
        let location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            NetworkManager.sharedManager.hideActivityIndicator(uiView: self.view)
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            if (placemarks?.count)! > 0 {
                if let pm = placemarks?[0]
                {
                    if let locality = pm.locality
                    {
                        completionHandler("\(locality)")
                    }
                    else
                    {
                        let alert = UIAlertController(title: nil, message: "Unable to detect location", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }

    func managedObjectContext() -> NSManagedObjectContext
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 10.0, *) {
            return appDelegate.persistentContainer.viewContext
        } else {
            return appDelegate.managedObjectContext
        }
    }
    
    @IBAction func confirmBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
}

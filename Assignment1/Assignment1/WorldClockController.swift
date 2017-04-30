//
//  WorldClockController.swift
//  Assignment1
//
//  Created by Renzelle Frank V Rodrigueza on 2017-03-06.
//  Copyright © 2017 com.renzellerodrigueza. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import AVFoundation

class WorldClockController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate {

    
    private static let savedLocationEntity = "SavedLocation"
    private static let savedLocalityKey = "locality"
    private static let savedCountryKey = "country"
    private static let savedDateKey = "date"
    private static let savedLocationID = "locationID"
    
    let cellTableIdentifier = "CellTableIdentifier"
    let locationManager = CLLocationManager()
    private var locationIDLists = [Int]()
    
    @IBOutlet weak var mKMapView: MKMapView!
    @IBOutlet var tableView:UITableView!
    
    @IBOutlet weak var saveLocationAndTimeButton: UIButton!

    let dateFormatter = DateFormatter();
    
    var listOfCountry = [
        ["Name" : "", "DateAndTime" : ""],
    ]
    var country = ""
    var regions = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CustomCell.self, forCellReuseIdentifier: cellTableIdentifier)
        let xib = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: cellTableIdentifier)
        tableView.rowHeight = 65.0
        dateFormatter.dateFormat = "MMMM dd, YYYY  hh:mm:ss"
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
           
        }
      
        retrieveData()
    }
    
    
 
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first

        let currentLat = (location?.coordinate.latitude)!
        let currentLong = (location?.coordinate.longitude)!
        
        let geoCoder = CLGeocoder()
        let currentLocation = CLLocation(latitude: currentLat, longitude: currentLong)
        geoCoder.reverseGeocodeLocation(currentLocation)
        {
            (placemarks, error) in
            
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
               
                
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    self.country = placemark.country!
                    self.regions = placemark.locality!
                } else {
                    print("No Matching address found")
                }
            }
        }
        
        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
       

        
        mKMapView.setRegion(region, animated: true)
        mKMapView.showsUserLocation = true
        mKMapView.showsBuildings = true
        mKMapView.showsCompass = true
        locationManager.stopUpdatingLocation()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
   
    @IBAction func onPressedSave(_ sender: UIButton) {
        
        let date = Date()
        let stringDate: String  = dateFormatter.string(from: date)
        
        if country.characters.count > 0
        {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: WorldClockController.savedLocationEntity)
            let pred = NSPredicate(format: "%K = %d", WorldClockController.savedLocalityKey)
            request.predicate = pred
            
            do {
                let objects = try context.fetch(request)
                var savedLocations:NSManagedObject! = objects.first as? NSManagedObject
                if savedLocations == nil {
                    savedLocations =
                        NSEntityDescription.insertNewObject(
                            forEntityName: WorldClockController.savedLocationEntity,
                            into: context)
                        as NSManagedObject
                }

                
                    savedLocations.setValue(country, forKey: WorldClockController.savedCountryKey)
                    savedLocations.setValue(regions, forKey: WorldClockController.savedLocalityKey)
                    savedLocations.setValue(stringDate, forKey: WorldClockController.savedDateKey)
                    savedLocations.setValue(locationIDLists.endIndex, forKey: WorldClockController.savedLocationID)
                
                
               
            } catch {
                print("There was an error in executeFetchRequest(): \(error)")
            }
        appDelegate.saveContext()
        let utterance = AVSpeechUtterance(string: "Successfully Saved Location")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        }
        else
        {
            let utterance = AVSpeechUtterance(string: "Unable to Save Location. Please enable Location Service on Settings")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
        retrieveData()
        tableView.reloadData()
    }
    
    func retrieveData()
    {
        listOfCountry.removeAll()
        locationIDLists.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: WorldClockController.savedLocationEntity)
        do {
            let objects = try context.fetch(request)
            
            for object in objects {
                let country = (object as AnyObject).value(forKey: WorldClockController.savedCountryKey) as? String ?? ""
                let regions = (object as AnyObject).value(forKey: WorldClockController.savedLocalityKey) as? String ?? ""
                let retrieveDate = (object as AnyObject).value(forKey: WorldClockController.savedDateKey) as? String ?? ""
                locationIDLists.append((object as AnyObject).value(forKey: WorldClockController.savedLocationID) as? Int ?? 0)
                listOfCountry.append(["Name": "\(country) \(regions)", "DateAndTime": retrieveDate])
            }
            
        } catch {
            print("There was an error in executeFetchRequest(): \(error)")
        }

    }
    
    
   
   func removeData(locationID: Int)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: WorldClockController.savedLocationEntity)
        do {
            request.predicate = NSPredicate.init(format: "locationID==\(locationID)")
            let objects = try context.fetch(request)
            if let savedLocation = objects.first as? NSManagedObject {
                context.delete(savedLocation)
            }
            
            
        } catch {
            print("There was an error in executeFetchRequest(): \(error)")
        }
        appDelegate.saveContext()
        let utterance = AVSpeechUtterance(string: "Successfully Remove Location")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- 
    //MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfCountry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath
        ) as! CustomCell
        
        
        let rowData = listOfCountry[indexPath.row]
        cell.location = rowData["Name"]!
        cell.dateTime = rowData["DateAndTime"]!
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     
        removeData(locationID:  locationIDLists[indexPath.row])
        listOfCountry.remove(at: indexPath.row)
        if editingStyle == UITableViewCellEditingStyle.delete
            {
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade
            )
        }
       
    }
    
    
    
}

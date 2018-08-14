//
//  ViewController.swift
//  Safe Pickup
//
//  Created by Andres Luis Sada Govela on 28/02/18.
//  Copyright © 2018 Andres Luis Sada Govela. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var originLocation: CLLocationCoordinate2D!
    var currentLocation: CLLocationCoordinate2D!
    
    var firebasePosRef:DatabaseReference?
    var pos = 0
    var rfcPoly = UIBezierPath()
    var rfePoly = UIBezierPath()

    lazy var firebaseRef = Database.database().reference() //asg shouldn't be here anymore

    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
//        print ("Requested when in use")
        // Ask for Authorisation from the User.

        if CLLocationManager.locationServicesEnabled() {
            print ("Enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.allowsBackgroundLocationUpdates = true

            locationManager.startUpdatingLocation()
        }

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.doesRelativeDateFormatting = false

        self.firebaseRef.child("Schools/0012/Doors/1/Zones").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let rfcString = value?["aprox"] as? String ?? ""
            let rfeString = value?["deliv"] as? String ?? ""
            
            self.rfcPoly = self.polygonFrom(rfcString)
            self.rfePoly = self.polygonFrom(rfeString)

        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func polygonFrom(_ string:String) -> UIBezierPath {
        var poly:[CGPoint] = []

        let components = string.components(separatedBy: " ")
        for object in components {
            let elements = object.components(separatedBy: ",")
            if elements.count > 1 {
                if let lat = NumberFormatter().number(from: elements[1]), let lng = NumberFormatter().number(from: elements[0]) {
                    poly.append(CGPoint(x: CGFloat(truncating:lng), y: CGFloat(truncating: lat)))
                }
            }
        }
        
        let p = UIBezierPath()
        if poly.count > 0 {
            p.move(to: poly[0])
            
            for index in 1..<poly.count {
                p.addLine(to: poly[index])
            }
            
            p.close()
        }

        return p
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue = manager.location?.coordinate {
            currentLocation = locValue
            guard let accuracy = manager.location?.horizontalAccuracy else { return }
            
            currentLocationLabel.text = "Actual: \(locValue.latitude), \(locValue.longitude)"
            accuracyLabel.text = "Certeza: \(accuracy)"
            
            if let origin = originLocation {
                let coordinate1 = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
                let coordinate2 = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
                
                let distanceInMeters = coordinate1.distance(from: coordinate2)

                distanceLabel.text = "Distance = \(distanceInMeters)"
                
                

            }
            let time = dateFormatter.string(from: Date())
            let deviceData = ["latitude": locValue.latitude,
                              "longitude": locValue.longitude,
                              "accuracy": accuracy,
                              "time": time] as [String : Any]

            if firebasePosRef == nil {
                firebasePosRef = self.firebaseRef.child("Position").childByAutoId()
            }
            firebasePosRef!.updateChildValues(deviceData)

            pos += 1
            
            print ("Updated lat:\(locValue.latitude), long\(locValue.longitude)")
//            // create a sound ID, in this case its the tweet sound.
//            let systemSoundID: SystemSoundID = 1016
//
//            // to play sound
//            AudioServicesPlaySystemSound (systemSoundID)
            
            
            let point = CGPoint(x: locValue.longitude, y: locValue.latitude)
            if rfcPoly.contains(point) {
                self.view.backgroundColor = .green
            }
            else if rfePoly.contains(point) {
                self.view.backgroundColor = .red
            }
            else {
                self.view.backgroundColor = .white
            }
        }
    }

    @IBAction func makeCurrentButtonPressed(_ sender: UIButton) {
        if let location = currentLocation {
            let lastLocation = originLocation
            originLocation = location
            originLabel.text = "Origen: \(location.latitude), \(location.longitude)"

            var distance:CLLocationDistance = 0.0
            if let lastLocation = lastLocation {
                let coordinate1 = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
                let coordinate2 = CLLocation(latitude: originLocation.latitude, longitude: originLocation.longitude)
                distance = coordinate1.distance(from: coordinate2)
            }
            else {
                distance = 0.0
            }

        }

        self.locationManager.requestAlwaysAuthorization()
        print ("Requested always")

        
    }
    
}


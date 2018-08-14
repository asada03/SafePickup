//
//  Door.swift
//  Safe Pickup
//
//  Created by Andres Luis Sada Govela on 13/08/18.
//  Copyright © 2018 Andres Luis Sada Govela. All rights reserved.
//

import UIKit
import CoreLocation

enum InZone: String {
    case none = "none"
    case willPU = "willPU"
    case delivery =  "deliv"
    case aproximation =  "aprox"
    case closeness = "close"
    
    var description: String {
        return self.rawValue
    }
}

class Door {
    let doorData:NSDictionary
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0
    var delivPoly = UIBezierPath()
    var aproxPoly = UIBezierPath()
    var closePoly = UIBezierPath()

    
    init(inData:NSDictionary) {
        doorData = inData
        
        if let zoneString = inData["deliv"] as? String {
            delivPoly = polygonFrom(zoneString)
            getFirstPoint(zoneString)
        }
        if let zoneString = inData["aprox"] as? String {
            aproxPoly = polygonFrom(zoneString)
        }
        if let zoneString = inData["close"] as? String {
            closePoly = polygonFrom(zoneString)
        }
    }
    
    private func polygonFrom(_ string:String) -> UIBezierPath {
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
    
    private func getFirstPoint(_ string:String) {
        let components = string.components(separatedBy: " ")
        for object in components {
            let elements = object.components(separatedBy: ",")
            if elements.count > 1 {
                if let lat = NumberFormatter().number(from: elements[1]), let lng = NumberFormatter().number(from: elements[0]) {
                    latitude = Double(truncating: lat)
                    longitude = Double(truncating: lng)
                }
                
                return // only the first one
            }
        }
    }
    
    func getDistanceForm(lat:CLLocationDegrees, lng:CLLocationDegrees) -> CLLocationDistance{
        let coordinate1 = CLLocation(latitude: lat, longitude: lng)
        let coordinate2 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        return coordinate1.distance(from: coordinate2)
    }
    
    func getZone(lat:CLLocationDegrees, lng:CLLocationDegrees) -> InZone {
        let point = CGPoint(x: lng, y: lat)
        if self.delivPoly.contains(point) {
            return .delivery
        }
        else if self.aproxPoly.contains(point) {
            return .aproximation
        }
        else if self.closePoly.contains(point) {
            return .closeness
        }
        else {
            return .none
        }
    }
}

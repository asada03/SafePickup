//
//  DayButton.swift
//  Safe Pickup
//
//  Created by Andres Luis Sada Govela on 13/09/18.
//  Copyright © 2018 Andres Luis Sada Govela. All rights reserved.
//

import UIKit

class DayButton: UIButton {

    var month = 0
    var date:Date!{
        didSet {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date)
            setTitle("\(calendar.component(.day, from: date))", for: .normal)
            print ("set title to:\(calendar.component(.day, from: date))")
            isEnabled = weekday > 1 && weekday < 7
        }
    }
    
    var toThis = false {
        didSet {
            chooseBackground()
        }
    }
    
    var toOthers = false {
        didSet {
            chooseBackground()
            
            if toOthers {
                isEnabled = false
            }
        }
    }
    
    func chooseBackground() {
        backgroundColor = toOthers ? #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 0.3424657534) : toThis ? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func clean() {
        setTitle("", for: .normal)
        isEnabled = false
        toThis = false
        toOthers = false
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func dateString() -> String {
        return DayButton.dateString(forDate:date)
    }
    
    class func dateString(forDate theDate:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyy"
        
        return dateFormatter.string(from: theDate)
    }
    
}

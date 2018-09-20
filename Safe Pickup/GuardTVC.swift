//
//  GuardTVC.swift
//  Safe Pickup
//
//  Created by Andres Luis Sada Govela on 30/08/18.
//  Copyright © 2018 Andres Luis Sada Govela. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class GuardTVC: UITableViewController {
    lazy var firebaseRef = Database.database().reference()

    var school = ""
    var classroom = ""

    var inDelivery:[NSDictionary] = []
    var inAprox:[NSDictionary] = []
    var inCloseness:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
            let mid = (4 - 5) / 2
        print ("\(mid)")
        // in delivery
        let delivString = "\(school)\(classroom)DV"
        firebaseRef.child("Students").queryOrdered(byChild: "statusK").queryEqual(toValue: delivString).observe(.childAdded, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSDictionary {
                self.inDelivery.insertInOrder(data) //asg should inser sorted
                self.tableView.reloadData()
            }
        })
        
        firebaseRef.child("Students").queryOrdered(byChild: "statusK").queryEqual(toValue: delivString).observe(.childRemoved, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSDictionary {
                self.inDelivery.removeDictionary(data)
                self.tableView.reloadData()
            }
        })
        
        firebaseRef.child("Students").queryOrdered(byChild: "statusK").queryEqual(toValue: delivString).observe(.childChanged, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSDictionary {
                self.inDelivery.removeDictionary(data)
                self.inDelivery.insertInOrder(data) //asg should inser sorted
                self.tableView.reloadData()
            }
        })

        // in aproximation
        let aproxString = "\(school)\(classroom)AP"
        firebaseRef.child("Students").queryOrdered(byChild: "statusK").queryEqual(toValue: aproxString).observe(.childAdded, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSDictionary {
                self.inAprox.insertInOrder(data)
                self.tableView.reloadData()
            }
        })
        
        firebaseRef.child("Students").queryOrdered(byChild: "statusK").queryEqual(toValue: aproxString).observe(.childRemoved, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSDictionary {
                self.inAprox.removeDictionary(data)
                self.tableView.reloadData()
            }
        })
        
        firebaseRef.child("Students").queryOrdered(byChild: "statusK").queryEqual(toValue: aproxString).observe(.childChanged, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSDictionary {
                self.inAprox.removeDictionary(data)
                self.inAprox.insertInOrder(data)
                self.tableView.reloadData()
            }
        })

        // in closeness
        let closeString = "\(school)\(classroom)CL"
        firebaseRef.child("Students").queryOrdered(byChild: "statusK").queryEqual(toValue: closeString).observe(.childAdded, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSDictionary {
                self.inCloseness.insertInOrder(data)
                self.tableView.reloadData()
            }
        })
        
        firebaseRef.child("Students").queryOrdered(byChild: "statusK").queryEqual(toValue: closeString).observe(.childRemoved, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSDictionary {
                self.inCloseness.removeDictionary(data)
                self.tableView.reloadData()
            }
        })
        
        firebaseRef.child("Students").queryOrdered(byChild: "statusK").queryEqual(toValue: closeString).observe(.childChanged, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSDictionary {
                self.inCloseness.removeDictionary(data)
                self.inCloseness.insertInOrder(data)
                self.tableView.reloadData()
            }
        })
    }
    
    // should I release al observers at dealoc???

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return inDelivery.count + inAprox.count > 0 ? inDelivery.count : 1
        case 1:
            return inAprox.count
        case 2:
            return inCloseness.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)
        var data:NSDictionary = [:]
        
        switch indexPath.section {
        case 0:
            data = inDelivery.count > 0 ? inDelivery[indexPath.row] : [:]
        case 1:
            data = inAprox[indexPath.row]
        case 2:
            data = inCloseness[indexPath.row]
        default:
            break
        }
        
        if let label = cell.viewWithTag(1) as? UILabel {
            let code = String((data["statusK"] as? String ?? "XX").suffix(2))
            label.text = "\(data["name"] as? String ?? "") \(data["lastName"] as? String ?? "")"
            
            switch InZone(rawValue: code) ?? .none {
            case .willPU:
                label.textColor = .black
            case .delivery:
                label.textColor = .red
            case .aproximation:
                label.textColor = .green
            case .closeness:
                label.textColor = .blue
            default:
                label.textColor = .black

            }
        }
        
        return cell
    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Entregar"
        case 1:
            return nil
        case 2:
            return "En Aproximación"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: header.textLabel?.font.fontName ?? "Arial", size: 24.0)
        header.textLabel?.textAlignment = NSTextAlignment.center
        //header.textLabel?.frame.size = CGSize(width: tableView.frame.width, height: 45.0)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 45.0
        case 1:
            return 0.0
        case 2:
            return 45.0
        default:
            return 0.0
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Array where Element == NSDictionary {
    mutating func removeDictionary(_ dict: NSDictionary) {
        for i in self.indices {
            let element = self[i]
            if let firstId = dict["id"] as? String, let secondId = element["id"] as? String, firstId == secondId {
                self.remove(at: i)
                break
            }
        }
    }

    mutating func insertInOrder(_ dict: NSDictionary) {
        let insertion = getInsertionIndex(forDict: dict)
        if insertion >= 0 {
            self.insert(dict, at: insertion)
        }
    }
    
    func getInsertionIndex(forDict dict: NSDictionary) -> Int {
        var first = 0
        var last = self.count - 1
        
        if last < 0 {
            return 0
        }
        
        while first <= last {
            let mid = (last - first) / 2
            let element = self[mid]
            print ("last:/(last) first:/(first) mid:/(mid)")
            if let distance = dict["distance"] as? Double, let elementDist = element["distance"] as? Double{
                if distance < elementDist {
                    last = mid - 1
                }
                else {
                    first = mid + 1
                }
            }
            else {
                return -1
            }
        }
        
        return first
    }
}

//
//  GuardChooserTVC.swift
//  Safe Pickup
//
//  Created by Andres Luis Sada Govela on 30/08/18.
//  Copyright © 2018 Andres Luis Sada Govela. All rights reserved.
//

import UIKit

class GuardChooserTVC: UITableViewController {
    
    var classrooms:[String] = []
    var doors:[String] = []
    var delivDoors:[String] = []
    var school = ""
    var classroom = ""

    var staff:NSDictionary! {
        didSet {
            let roomsString = staff["class"] as? String ?? ""
            let doorsString = staff["door"] as? String ?? ""
            let delivString = staff["deliv"] as? String ?? ""
            
            school = staff["school"] as? String ?? ""
            classrooms = roomsString == "" ? [] : roomsString.components(separatedBy: "|")
            doors = doorsString == "" ? [] : doorsString.components(separatedBy: "|")
            delivDoors = delivString == "" ? [] : delivString.components(separatedBy: "|")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

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
            return classrooms.count
        case 1:
            return doors.count
        case 2:
            return delivDoors.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)
        var array:[String] = []

        switch indexPath.section {
        case 0:
            array = classrooms
        case 1:
            array = doors
        case 2:
            array = delivDoors
        default:
            break
        }
        
        if let label = cell.viewWithTag(1) as? UILabel, indexPath.row < array.count {
            label.text = array[indexPath.row]
        }

        return cell
    }

//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerText = UILabel()
//        headerText.textAlignment = .center
//        headerText.textColor = UIColor.lightGray
//        headerText.adjustsFontSizeToFitWidth = true
//
//        switch section{
//        case 0:
//            if classrooms.count > 0 {
//                headerText.text = "Cuidar Salon"
//                return headerText
//            }
//        case 1:
//            if doors.count > 0 {
//                headerText.text = "Cuidar Entrada"
//            }
//        case 2:
//            if delivDoors.count > 0 {
//                headerText.text = "Entregar en Entrada"
//            }
//        default:
//            break
//        }
//
//        return nil
//    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return classrooms.count > 0 ? "Cuidar Salon": nil
        case 1:
            return doors.count > 0 ? "Cuidar Entrada" : nil
        case 2:
            return delivDoors.count > 0 ? "Entregar en Entrada" : nil
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
        var hasRows = false
        switch section {
        case 0:
            hasRows = classrooms.count > 0
        case 1:
            hasRows = doors.count > 0
        case 2:
            hasRows = delivDoors.count > 0
        default:
            break
        }
        
        return hasRows ? 45.0 : 0.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            classroom = classrooms[indexPath.row]
            performSegue(withIdentifier: "toGuardView", sender: self)
        case 1:
            break
        case 2:
            break
        default:
            break
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toGuardView" {
            let destination = segue.destination as! GuardTVC
            
            destination.classroom = classroom
            destination.school = school
        }
    }

}

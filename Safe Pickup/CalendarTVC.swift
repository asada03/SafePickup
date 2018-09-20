//
//  CalendarTVC.swift
//  Safe Pickup
//
//  Created by Andres Luis Sada Govela on 13/09/18.
//  Copyright © 2018 Andres Luis Sada Govela. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CalendarTVC: UITableViewController  {
    
    lazy var firebaseRef = Database.database().reference()

    let monthFormatter = DateFormatter()
    let dayFormatter = DateFormatter()
    var userId = ""
    var userCode = ""
    var userName = ""
    var userNotFound = false {
        didSet {
            if userNotFound {
                userName = ""
            }
        }
    }
    var studentId = ""
    var userCodeTextField: UITextField!

    var firstWeekday = 0
    var toThisPerson:[String] = []
    var toOthers:[String] = []
    
    var hasChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        tableView.tableFooterView = UIView()
        
        monthFormatter.dateFormat = "LLLL YYYY"
        dayFormatter.dateFormat = "dd/MM/yy"
    
    }

    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController, hasChanged {
            let transferString = toThisPerson.joined(separator: ",")
            let transferData = ["to":userId,
                                "student":studentId,
                                "name":userName,
                                "transfers":transferString] as [String : Any]
            
            firebaseRef.child("Transfers/\(studentId)\(userId.suffix(K.Data.numberOfDigitsForKey))").updateChildValues(transferData)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadTransfers() {
        toOthers = []
        toThisPerson = []
        firebaseRef.child("Transfers").queryOrdered(byChild:"student").queryEqual(toValue: studentId).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                for (_, element) in value {
                    //print ("key:\(key) transfers:\(transfers as? String ?? "***")")
                    if let element = element as? NSDictionary {
                        if let transfers = element["transfers"] as? String, let user = element["to"] as? String {
                            if user == self.userId {
                                print("To this person")
                                self.toThisPerson = transfers.components(separatedBy: ",")
                            }
                            else {
                                print("To others")
                                self.toOthers += transfers.components(separatedBy: ",")
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    private func findUser() {
        userNotFound = false
        firebaseRef.child("Users").queryOrdered(byChild: "code").queryEqual(toValue: userCode).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary, value.count > 0 {
                for (key, user) in value {
                    print ("key:\(key) user:\(user as? String ?? "***")")
                    if let key = key as? String, let user = user as? NSDictionary {
                        self.userName = user["name"] as? String ?? ""
                        self.userId = key
                        self.loadTransfers()
                        break
                    }
                    else {
                        self.userNotFound = true
                    }
                }
            }
            else {
                self.userNotFound = true
            }
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return userName == "" ? 1 : 13
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCodeCell", for: indexPath)
            if let nameLabel = cell.viewWithTag(2) as? UILabel {
                userCodeTextField = cell.viewWithTag(1) as? UITextField
                userCodeTextField.delegate = self
                userCodeTextField.text = userCode
                userCodeTextField.isEnabled = !hasChanged
                
                if userNotFound {
                    nameLabel.text = "No se encontro a este usuario"
                    nameLabel.textColor = .red
                }
                else {
                    nameLabel.text = userName == "" ? "Ingrese la clave del usuario" : userName
                    nameLabel.textColor = #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
                }
            }
            return cell
        }
        else {
            let monthIndex = indexPath.section - 1

            let cell = tableView.dequeueReusableCell(withIdentifier: "monthCell", for: indexPath)
            
            let calendar = Calendar.current
            let monthDate = calendar.date(byAdding: .month, value: monthIndex, to: Date())!
            
            let firstOfMonthDate = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
            let dayOfMonth = calendar.component(.day, from: monthDate)
            let dayOfWeek = calendar.component(.weekday, from: firstOfMonthDate)
            
            let range = calendar.range(of: .day, in: .month, for: firstOfMonthDate)!
            let numDays = range.count
            print ("updating month: \(monthIndex)")
            // Configure the cell...
            for i in (1...42) {
                if let button = cell.viewWithTag(i) as? DayButton {
                    button.clean()
                    let thisDay = i - dayOfWeek + 1
                    if thisDay > 0 && thisDay <= numDays {
                        button.date = calendar.date(byAdding: .day, value: thisDay - 1, to: firstOfMonthDate)
                        button.month = monthIndex
                        button.toThis = toThisPerson.contains(button.dateString())
                        button.toOthers = toOthers.contains(button.dateString())
                        if monthIndex == 0 && thisDay < dayOfMonth {
                            button.isEnabled = false
                        }
                    }
                }
            }
            
            return cell
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return nil
        }
        else {
            let month = Calendar.current.date(byAdding: .month, value: section-1, to: Date())!
            return monthFormatter.string(from: month)
        }
    }

    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: header.textLabel?.font.fontName ?? "Arial", size: 24.0)
        header.textLabel?.textAlignment = NSTextAlignment.center
        //header.textLabel?.frame.size = CGSize(width: tableView.frame.width, height: 45.0)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func codeTextFieldEditingEnded(_ sender: UITextField) {
        userCode = sender.text!
        findUser()
    }
    
    @IBAction func dayButtonPressed(_ sender: DayButton) {
        print ("Pressed button with date: \(sender.dateString())")
        let dateString = sender.dateString()
        if let index = toThisPerson.index(of: dateString) {
            toThisPerson.remove(at: index)
        }
        else {
            toThisPerson.append(dateString)
        }
        
        if !hasChanged {
            hasChanged = true
            tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
        }
        //tableView.reloadData()
        tableView.reloadRows(at: [IndexPath(item: 0, section: sender.month+1)], with: .none)
    }
}

extension CalendarTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        return !hasChanged;
//    }
}

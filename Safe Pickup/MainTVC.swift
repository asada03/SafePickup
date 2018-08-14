//
//  MainTVC.swift
//  Safe Pickup
//
//  Created by Andres Luis Sada Govela on 28/07/18.
//  Copyright © 2018 Andres Luis Sada Govela. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth


class MainTVC: UITableViewController {

    lazy var firebaseRef = Database.database().reference()
    let locationManager = CLLocationManager()
    var userId:String!
    var loggedIn = false
    var students:[String:NSMutableDictionary] = [:]
    var studentKeys:[String] = []
    var schools:[String:NSMutableDictionary] = [:]
    var doors:[String:Door] = [:]
    let dateFormatter = DateFormatter()
    var lastDate = ""
    var lastLocationUpdate:TimeInterval = 0.0
    
    var firebasePosRef:DatabaseReference?



    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.tableFooterView = UIView()
        
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
            
        }

        signIn()
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        dateFormatter.dateFormat = "ddMMyy"
        let date = dateFormatter.string(from: Date())
        lastDate = date

        cleanAllStudents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func signIn() {
        Auth.auth().signInAnonymously() { (user, error) in
            // ...
            if error == nil, user != nil {
                let uid = user!.user.uid
                
                let keychain = Keychain(service: K.Keychain.service)
                self.userId = keychain["UserID"]
                
                if self.userId == nil {
                    
                    self.createUser(uid:uid)
                }
                else {
                    self.start()
                }
            }
        }
        
        for _ in 1...100 {
            print ("\(makeCode())")
        }
    }
    
    private func createUser(uid:String) {
        let code = makeCode()
        
        self.firebaseRef.child("Users/").queryOrdered(byChild: "code").queryEqual(toValue: code).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? NSMutableDictionary, data.count > 0 {
                self.createUser(uid: uid) //code already in use. Try again
            }
            else {
                let deviceData = ["creation": Date().timeIntervalSinceReferenceDate,
                                  "deviceName": UIDevice.current.name,
                                  "code":code] as [String : Any]
                let deviceRef = self.firebaseRef.child("Users").child(uid)
                
                print ("**id: \(deviceRef.key) = \(uid)")
                deviceRef.setValue(deviceData)
                
                let keychain = Keychain(service: K.Keychain.service)
                keychain["UserID"] = uid
                self.userId = uid
                self.start()
            }
        })

        print ("done")
    }
    
    private func start() {
        loggedIn = true
        tableView.reloadData()
        
        print ("programming with userId:\(self.userId)")
        
        firebaseRef.child("Students").queryOrdered(byChild: "parent").queryEqual(toValue: self.userId).observe(.childAdded, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSMutableDictionary {
                self.students[snapshot.key] = data
                self.cleanStudent(snapshot.key)
                self.tableView.reloadData()
                
            }
        })
        
        firebaseRef.child("Students").queryOrdered(byChild: "parent").queryEqual(toValue: self.userId).observe(.childChanged, with: { (snapshot) -> Void in
            if let data = snapshot.value as? NSMutableDictionary {
                if self.students[snapshot.key] != nil {
                    self.students[snapshot.key] = data
                    self.cleanStudent(snapshot.key)
                    self.tableView.reloadData()
                }
            }
        })
        
        firebaseRef.child("Students").queryOrdered(byChild: "parent").queryEqual(toValue: self.userId).observe(.childRemoved, with: { (snapshot) -> Void in
            self.students.removeValue(forKey: snapshot.key)
        })
        
    }
    
    private func cleanStudent(_ key:String) {
        
        print ("looking for student:\(key) in:\(students)")
        if let student = students[key] {
            if let date = student["date"] as? String {
                if date != lastDate {
                    let sessionData = [
                        "session": "",
                        "status": "",
                        "date": ""]
                    
                    self.firebaseRef.child("Students/\(key)").updateChildValues(sessionData)
                }
            }
        }
    }
    
    private func cleanAllStudents()
    {
        for key in Array(students.keys) {
            cleanStudent(key)
        }
    }
    
    private func studentNotAvailable()
    {
        let alert = UIAlertController(title: "Alumno no Disponible",
                                      message: "Este alumno no esta disponible, por favor revise los datos e intente de nuevo.\n\nSi cree que esto es un error contacte a la dirección de su colegio inmediatamente",
                                      preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        // Add 1 textField and customize it
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)

    }
    
    private func addStudent () {
        let alert = UIAlertController(title: "Agregar Alumno",
                                      message: "Ingrese los siguientes datos para agregar al alumno",
                                      preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title:"Agregar", style: .default, handler: { (action) -> Void in
            
            let school = alert.textFields![0].text!
            let student = alert.textFields![1].text!
            
            print ("Colegio:\(school) Alumno:\(student)")
            
            self.firebaseRef.child("Students/\(school)-\(student)").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                if let value = snapshot.value as? NSDictionary {
                    let parentString = value["parent"] as? String ?? ""
                    
                    if parentString == "" {
                        let parentData = ["parent":self.userId] as [String : Any]
                        
                        self.firebaseRef.child("Students/\(school)-\(student)").updateChildValues(parentData)
                    }
                    else {
                        print ("11111")
                        self.studentNotAvailable()
                    }
                }
                else {
                    print ("3333")
                    self.studentNotAvailable()
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }


        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancelar", style: .destructive, handler: { (action) -> Void in })
        // Add 1 textField and customize it
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .numberPad
            textField.autocorrectionType = .default
            textField.clearButtonMode = .whileEditing
            textField.text = ""
            textField.placeholder = "Numero de Colegio"
        }
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .numberPad
            textField.autocorrectionType = .default
            textField.clearButtonMode = .whileEditing
            textField.text = ""
            textField.placeholder = "Numero del Alumno"
        }
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)

    }

    private func willPickUp() {
        dateFormatter.dateFormat = "ddMMyy"
        let date = dateFormatter.string(from: Date())
        var studentsAvailable = false
        
        self.locationManager.requestAlwaysAuthorization()

        for (key, student) in students {
            let sessionData = ["session": "\(date)\(student["class"] ?? "")",
                "date": date]
            
            self.firebaseRef.child("Students/\(key)").updateChildValues(sessionData)
            
            studentsAvailable = true
            
            if let schoolNum = student["school"] as? String, let doorNum = student["door"] as? String {
                let schoolDoor = schoolNum + doorNum
                
                if self.doors[schoolDoor] == nil,
                    let schoolData = self.schools[schoolNum]{
                    print ("schoolData:\(schoolData)")
                    if let doorsData = schoolData["Doors"] as? NSDictionary{
                        if let doorData = doorsData[doorNum] as? NSDictionary{
                            self.doors[schoolDoor] = Door(inData: doorData)
                        }
                    }
                }
            }
        }

        if studentsAvailable {
            locationManager.startUpdatingLocation() //asg when do we stop
        }
    }
    
    private func getSchool(_ schoolNum:String) -> NSMutableDictionary? {
        var retVal:NSMutableDictionary?
        if let school = schools[schoolNum] {
            retVal = school
        }
        else {
            self.firebaseRef.child("Schools/\(schoolNum)").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? NSMutableDictionary {
                    self.schools[snapshot.key] = data
                    print ("......\n......\n......\n......\n......\n......\n")
                    print ("\(data)")
                    retVal = data
                    self.tableView.reloadData()
                }
            })
        }
        return retVal
    }
    
    private func makeCode() -> String {
//        let chars = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","m","n","p","q","r","s","t","u","v","w","x","y","z"]
        
        let chars = ["0","1","2","3","4","5","6","7","8","9","a","e","i","u","h","j","k","q","r","x","z"]
        
        var retString = ""
    
        for i in 1...6 {
            let num = Int(arc4random_uniform(UInt32(chars.count)))
            retString += chars[num]
        }
        
        return retString
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            studentKeys = Array(students.keys)
            return studentKeys.count
        }
        else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! StudentCell
            
            let key = studentKeys[indexPath.row]
            if let student = students[key] {
                cell.nameLabel.text = student["name"] as? String ?? ""
                cell.lastNameLabrel.text = student["lastName"]  as? String ?? ""
                cell.classroomLabel.text = student["class"] as? String ?? ""
                var school:NSMutableDictionary?
                
                if let schoolNum = student["school"] as? String {
                    school = getSchool(schoolNum)
                }
                
                switch InZone(rawValue: student["status"] as? String ?? "none") ?? .none {
                case .willPU:
                    cell.messageLabel.text = "En camino a recogerlo"
                    cell.containerView.backgroundColor = .white
                case .delivery:
                    cell.messageLabel.text = "En Entrega"
                    cell.containerView.backgroundColor = .red
                case .aproximation:
                    cell.messageLabel.text = "En Aproximación"
                    cell.containerView.backgroundColor = .green
                case .closeness:
                    cell.messageLabel.text = "En Cercania"
                    cell.containerView.backgroundColor = .blue
                default:
                    cell.containerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                    if let school = school {
                        cell.messageLabel.text = school["name"] as? String ?? ""
                    }
                    else {
                        cell.messageLabel.text = ""
                    }
                }
            }
            // Configure the cell...
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
            
            // Configure the cell...
            let buttonLabel = cell.viewWithTag(1) as! UILabel
            
            buttonLabel.text = indexPath.row == 0 ? "Agregar Alumno" : "En Camino por Ellos"
            
            return cell

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if loggedIn == false {
            return
        }
        
        if indexPath.section == 0 {
            
            }
        else {
            if indexPath.row == 0 {
                addStudent()
            }
            else {
                willPickUp()
            }
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

extension MainTVC: CLLocationManagerDelegate {
    // MarK: - Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue = manager.location?.coordinate {
            guard let accuracy = manager.location?.horizontalAccuracy else { return }
            
            let time = Date().timeIntervalSince1970
            
            if time > lastLocationUpdate + 3.0 {
                lastLocationUpdate = time
                
                let deviceData = ["latitude": locValue.latitude,
                                  "longitude": locValue.longitude,
                                  "accuracy": accuracy,
                                  "time": time] as [String : Any]
                
                if firebasePosRef == nil {
                    firebasePosRef = self.firebaseRef.child("Position").childByAutoId()
                }
                firebasePosRef!.updateChildValues(deviceData)

                
                for (key, door) in self.doors {
                    let distance = door.getDistanceForm(lat: locValue.latitude, lng: locValue.longitude)
                    let zone = door.getZone(lat: locValue.latitude, lng: locValue.longitude)
                    
                    for (stKey,student) in self.students {
                        if let school = student["school"] as? String, let door = student["door"] as? String {
                            if school + door == key {
                                
                                let sessionData = ["lat": locValue.latitude,
                                                   "lng": locValue.longitude,
                                                   "accuracy": accuracy,
                                                   "time": time,
                                                   "distance" : distance,
                                                   "status" : zone.description] as [String : Any]
                                
                                self.firebaseRef.child("Students/\(stKey)").updateChildValues(sessionData)
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            }
            else {
                print("*** Tiime not elapsed")
            }
        }
    }

}
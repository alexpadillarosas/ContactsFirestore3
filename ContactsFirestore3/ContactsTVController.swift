//
//  ContactsTVC.swift
//  ContactsFirestore1
//
//  Created by alex on 23/3/2023.
//

import UIKit

class ContactsTVController: UITableViewController {
    
    let service = ContactRepository()
    var contacts = [Contact]()
    var selectedContact : Contact!
    
    @IBOutlet var contactsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        _ = service.db.collection("Contacts")
            .addSnapshotListener { querySnapshot, error in
                if let documents = querySnapshot?.documents {
                    self.contacts = documents.compactMap({ queryDocumentSnapshot -> Contact? in
                        let data = queryDocumentSnapshot.data()
                        return Contact(id: queryDocumentSnapshot.documentID, dictionary: data)
                    })
                    
                    for contact in self.contacts {
                        print(contact.toString())
                    }
                    self.contactsTableView.reloadData()
                }else{
                    print("Error fetching documents \(error!)")
                    return
                }
                
            }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactIdentifier", for: indexPath) as! ContactTVCell

        // Configure the cell...
        let contact = contacts[indexPath.row]
        
        //if there is an image to look for in the assests folder and the image exists
        if !contact.photo.isEmpty && UIImage(named: contact.photo) != nil {
            cell.photoImageView.image = UIImage(named: contact.photo)
        }else{//This else is needed to reset the default image, else gets cached it and display the wrong one whenever the image cannot be found in the project
            cell.photoImageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        cell.nameLabel.text = contact.name
        cell.positionLabel.text = contact.position
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selectedContact = contacts[indexPath.row]
        return indexPath
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let contact = contacts[indexPath.row]
            deleteConfirmationMessage(title: "Delete Contact",
                                      message: "Are you sure you want to permanently delete \(contact.name) ?",
                                      delete: {
                                                if self.service.delete(contact: contact) {
                                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                                    print("deleted")
                                                }
                                            
                                              },
                                      cancel: {
                                                print("cancelled")
                                              }
                                     )

            

            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let viewContactTVC = segue.destination as? ViewContactTVController {
            viewContactTVC.contact = selectedContact
        }
    }
    
    @IBAction func unwindToContactsTVController(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        if let editContactTVC = sourceViewController as? EditContactTVController {
            if service.update(contact: self.selectedContact){
                print("Contact Updated")
            }
        }
        if let addContactTVC = sourceViewController as? AddContactTVController {
            if service.add(contact: self.selectedContact){
                print("Contact Added")
            }
        }
    }

    
    func showAlertMessage(title : String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true)
    }
    
    /**
        Using closures:
              If we want to pass code that will get executed inside of a function as a parameter, then create a closure.
              The way to declare this parameters is:   parameter name : ( () -> Void )?
                     The question mark ? is optional, if we add it, it means the parameter might contain a value or not, wihout ? it could not be nil.
     */
    
    func deleteConfirmationMessage(title : String, message : String, delete : ( () -> Void )?, cancel: ( () -> Void )? ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)

        
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive) {
            action -> Void in delete?()
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .default) {
            action -> Void in cancel?()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        self.present(alert, animated: true)
        
    }
}


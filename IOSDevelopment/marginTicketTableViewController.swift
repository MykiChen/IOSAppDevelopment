//
//  marginTicketTableViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/25.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class marginTicketTableViewController: UITableViewController {

    // MARK: Properties
    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    
    var marginTickets = [MarginTicket]()
    
    var maxNumber: Int32 = -1
    var soldNumber: Int32 = 0
    
    var marginName: String = "Hello"
    var ticketNumber: Int32 = 0
    var ticketPrice: Int32 = 12
    var startDate: String = "00/00/2020"
    var startTime: String = "00:00"
    var customerName: String = ""
    var purchaseDate: String = ""
    var purchaseTime: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSpecificMarginTickets(raffleName: marginName)
        
        updateButtonState()
                
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //MARK: - Disable the add button if the sold number is beyond or equal to the max number.
//        if (soldNumber >= maxNumber) {
//            self.navigationItem.rightBarButtonItem?.isEnabled = false
//            print("Sorry, you cannot add new ticket for this raffle since the number of ticket is limited by the max number.")
//            
//        } else {
//            print("You can add a ticket now~~")
//        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return marginTickets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "marginTicketTableViewCell", for: indexPath)
        //let cell = tableView.dequeueReusableCell(withIdentifier: "RaffleTableViewCell", for: indexPath)
        
        // Configure the cell...
        let marginTicket = marginTickets[indexPath.row]
        
        if let ticketCell = cell as? marginTicketTableViewCell {
            
            ticketCell.raffleNameLabel.text = marginTicket.raffleName
            
            ticketCell.ticketNumberLabel.text = String(marginTicket.ticketNumber)
            ticketCell.priceLabel.text = String(marginTicket.price)
            ticketCell.customerNameLabel.text = String(marginTicket.customerName)
            ticketCell.purchaseDateLabel.text = marginTicket.purchaseDate
            ticketCell.purchaseTimeLabel.text = marginTicket.purchaseTime
            ticketCell.startDateLabel.text = marginTicket.startDate
            ticketCell.startTimeLabel.text = marginTicket.startTime
            
//            print("#$@#%@#$@#")
//            print(marginTicket.purchaseTime)
        }
        
        return cell
        
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        // Get current date
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/YYYY"
        let date = dateformatter.string(from: Date())
        
        // get current time
        let dateformatter2 = DateFormatter()
        dateformatter2.dateFormat = "HH:mm"
        let time = dateformatter2.string(from: Date())
        
        if segue.identifier == "addMarginTicket" {
            
            print("Add a new ticket here")
            
            guard let ticketDetailViewController = segue.destination as? addMarginTicketViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            ticketDetailViewController.marginName = marginName
            ticketDetailViewController.purchaseTime = time
            ticketDetailViewController.purchaseDate = date
            ticketDetailViewController.maxNumber = maxNumber
            ticketDetailViewController.price = ticketPrice
            ticketDetailViewController.sDate = startDate
            ticketDetailViewController.sTime = startTime
            ticketDetailViewController.cName = customerName
//            print("$$$$$")
//            print(ticketDetailViewController.price)

        }
    }
    
    
    
    @IBAction func unwindToMarginTicketList(sender: UIStoryboardSegue) {

        if let sourceViewController = sender.source as? addMarginTicketViewController, let marginTicket = sourceViewController.marginTicket {

            if let selectedIndexPath = tableView.indexPathForSelectedRow {

                // Update an existing ticket
                marginTickets[selectedIndexPath.row] = marginTicket

                tableView.reloadRows(at: [selectedIndexPath], with: .none)

                database.updateQuery(updateQueryStatement: "UPDATE MarginTicket SET ticketNumber = \(marginTicket.ticketNumber), customerName = '\(marginTicket.customerName)' WHERE purchaseTime = '\(purchaseTime)' and purchaseDate = '\(purchaseDate)';")

                print("Update an existing raffle")

            } else {
                //
                //                if (soldNumber < maxNumber) {
                
                // Add a new ticket here
                let newIndexPath = IndexPath(row: marginTickets.count, section: 0)
                
                marginTickets.append(marginTicket)
                
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                database.insert(marginTicket: MarginTicket(
                    raffleName: marginTicket.raffleName,
                    ticketNumber: marginTicket.ticketNumber,
                    purchaseTime: marginTicket.purchaseTime,
                    purchaseDate: marginTicket.purchaseDate,
                    startDate: marginTicket.startDate,
                    startTime: marginTicket.startTime,
                    price: marginTicket.price,
                    customerName: marginTicket.customerName))
                
                let totalSold = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM MarginTicket WHERE raffleName = '\(marginTicket.raffleName)';")
                
                //MARK: - Disable the add button if the sold number is beyond or equal to the max number.
                if (totalSold >= maxNumber) {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    print("Sorry, you cannot add a new ticket for this raffle since the number of ticket is limited by the max number.")
                    
                } else {
                    print("You can add a ticket now~~")
                }
                
                
                print("Adding a new ticket.")
                
                //                } else {
                //                    print("Error happeded.")
                //                    print("Sorry, you cannot add new ticket for this raffle since the number of ticket is limited by the max number.")
            }
            //            }
        }
    }
    
    func loadMarginTickets() {
        
        marginTickets = database.selectAllMarginTickets()
    }
    
    func loadSpecificMarginTickets(raffleName: String) {
        
        marginTickets = database.selectMarginTicketBy(raffleName: raffleName)!
    }
    
    func updateButtonState() {
        
        //MARK: - Disable the add button if the sold number is beyond or equal to the max number.
        if (soldNumber >= maxNumber) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            print("Sorry, you cannot add a new ticket for this raffle since the number of ticket is limited by the max number.")
            
        } else {
            print("You can add a ticket now~~")
        }
    }

}

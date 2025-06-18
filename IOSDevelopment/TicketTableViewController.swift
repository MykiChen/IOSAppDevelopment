//
//  TicketTableViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/22.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class TicketTableViewController: UITableViewController {
    
    // MARK: Properties
    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    
    var tickets = [Ticket]()
    
    var maxNumber: Int32 = -1
    var soldNumber: Int32 = 0
    
    var raffleName: String = "MYKI Raffle"
    var ticketPrice: Int = 12
    var startDate: String = "06/08/2020"
    var startTime: String = "24:00"
    var NoTicket: Int = 100000
    var purchaseDate: String = ""
    var purchaseTime: String = ""
    
    static var allTicketsScreen : TicketTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setEditing(false, animated: true)
        
        if navigationItem.title == "Tickets" {
            loadTicketDate(raffleName: raffleName)
            updateButtonState()
            
        } else {
            TicketTableViewController.allTicketsScreen = self
            loadAllTickets()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tickets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTableViewCell", for: indexPath)

        // Configure the cell...
        let ticket = tickets[indexPath.row]
        
        if let ticketCell = cell as? TicketTableViewCell {
            
            ticketCell.raffleName.text = ticket.raffleName
            ticketCell.purchaseTime.text = ticket.purchaseTime
            ticketCell.purchaseDate.text = ticket.purchaseDate
            ticketCell.ticketNumber.text = String(ticket.ticketNumber)
            ticketCell.customerName.text = ticket.customerName
            ticketCell.NoTicket.text = ticket.NoTicket
            
            ticketCell.startDate.text = ticket.startDate
            ticketCell.startTime.text = ticket.startTime
            
            ticketCell.ticketPrice.text = String(ticket.ticketPrice)
            
            purchaseDate = ticketCell.purchaseDate.text ?? ""
            purchaseTime = ticketCell.purchaseTime.text ?? ""
//            ticketPrice = Int(ticketCell.ticketPrice.text!)!
            
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
    
    // MARK: - Actions
    
    @IBAction func unwindToTicketList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? TicketDetailViewController, let ticket = sourceViewController.ticket {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                // Update an existing ticket
                tickets[selectedIndexPath.row] = ticket
                
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
                database.updateQuery(updateQueryStatement: "UPDATE Ticket SET ticketNumber = \(ticket.ticketNumber), customerName = '\(ticket.customerName)' WHERE purchaseTime = '\(purchaseTime)' and purchaseDate = '\(purchaseDate)';")
                
                loadTicketDate(raffleName: ticket.raffleName)
                
                print("Update an existing raffle")
                
            } else {
                // Add a new ticket here
                let newIndexPath = IndexPath(row: tickets.count, section: 0)
                
                tickets.append(ticket)
                
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                let totalCount = tableView.numberOfRows(inSection: 0)
            
                database.insert(ticket: Ticket(raffleName: ticket.raffleName, ticketNumber: ticket.ticketNumber, ticketPrice: ticket.ticketPrice, purchaseTime: ticket.purchaseTime, purchaseDate: ticket.purchaseDate, startDate: ticket.startDate, startTime: ticket.startTime, NoTicket: ticket.NoTicket, customerName: ticket.customerName, singleTicket: ticket.singleTicket))
                
                print("Adding a new ticket.")
                
                if totalCount >= maxNumber {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    print("Sorry, your sold number is equals to the max number now. So you cannot add new ticket for this raffle.")
                    
                }
                
                TicketTableViewController.allTicketsScreen?.loadAllTickets()
                TicketTableViewController.allTicketsScreen?.tableView.reloadData()
                
            }
        }
    }
    
    
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
        
        // generate a specific No number for a ticket.
        let day = date.split(separator: "/")[0]
        let month = date.split(separator: "/")[1]
        let hour = time.split(separator: ":")[0]
        let minute = time.split(separator: ":")[1]
        
        if segue.identifier == "AddTicket" {
            print("Add a new ticket here.")
            
            guard let ticketDetailViewController = segue.destination as? TicketDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            ticketDetailViewController.soldNumber = soldNumber
            ticketDetailViewController.maxNumber = maxNumber
            
            ticketDetailViewController.ticketPrice = String(ticketPrice)
            ticketDetailViewController.purchaseTime = time
            ticketDetailViewController.purchaseDate = date
            ticketDetailViewController.raffleName = raffleName
            ticketDetailViewController.ticketPrice = String(ticketPrice)
            ticketDetailViewController.startDate = startDate
            ticketDetailViewController.startTime = startTime
            ticketDetailViewController.NoTicket = Int(month + day + hour + minute)!
            
        } else if segue.identifier == "showTicketDetail" {
            
            guard let detailViewController = segue.destination as? TicketDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // use the sender parameter to work out which cell in the UITableView was tapped.
            guard let selectedTicketCell = sender as? TicketTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTicketCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // we use that index to get the selected ticket, and pass this to the DetailViewController
            let selectedTicket = tickets[indexPath.row]
            
            detailViewController.ticketPrice = String(ticketPrice)
            
            detailViewController.ticket = selectedTicket
            detailViewController.startDate = selectedTicket.startDate
            detailViewController.startTime = selectedTicket.startTime
            detailViewController.purchaseDate = purchaseDate
            detailViewController.purchaseTime = purchaseTime
            detailViewController.raffleName = selectedTicket.raffleName
            detailViewController.NoTicket = Int(month + day + hour + minute)!
            
        }
    }
    
    
    // MARK: - Private Methods
    
    private func loadTicketDate(raffleName: String) {
        
        tickets = database.selectTicketBy(raffleName: raffleName)!
    }
    
    private func loadAllTickets() {
        tickets = database.selectAllTickets()
    }
    
    private func updateButtonState() {
        //MARK: - Disable the add button if the sold number is beyond or equal to the max number.
        if (soldNumber >= maxNumber) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            print("Sorry, you cannot add new ticket for this raffle since the number of ticket is limited by the max number.")
            
        } else {
            print("You can add a ticket now~~")
        }
    }
}

//
//  MarginTableViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/25.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class MarginTableViewController: UITableViewController {

    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    
    // MARK: Initialization

    var marginRaffles = [MarginRaffle]()
    
    var raffleName: String = "MYKI Raffle"
    var ticketPrice: Int = 12
    var prize: Int = 0
    var startDate: String = "06/08/2020"
    var startTime: String = "24:00"
    var maxNumber: Int = 0
    var soldNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.setEditing(false, animated: true)
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        database.createMarginTable()
        
        loadRafflesData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return marginRaffles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "marginTableViewCell", for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "RaffleTableViewCell", for: indexPath)
        
        // Configure the cell...
        let marginRaffle = marginRaffles[indexPath.row]
        
        if let raffleCell = cell as? marginTableViewCell {
            raffleCell.raffleNameLabel.text = marginRaffle.raffleName
            raffleCell.prizeLabel.text = String(marginRaffle.prize)
            raffleCell.startTimeLabel.text = marginRaffle.startTime
            raffleCell.startDateLabel.text = marginRaffle.startDate
            raffleCell.selectWinnerButton.setTitle("Select a winner " + String(indexPath.row + 1) + " >", for: UIControl.State.normal)
            
            // get the total number of sold tickets for this margin raffle
            let cellSoldNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM MarginTicket WHERE raffleName = '\(marginRaffle.raffleName)';")
            
            let soldButtonText = " Sold: \(String(cellSoldNumber))"
            
            let maxButtonText = " Tickets: \(String(marginRaffle.maxNumberOfRaffle))"
            let cellPrice = " $ \(String(marginRaffle.price)) /ticket"
            
            raffleCell.maxNumberButton.setTitle(maxButtonText, for: UIControl.State.normal)
            raffleCell.soldButton.setTitle(soldButtonText, for: UIControl.State.normal)
            raffleCell.priceButton.setTitle(cellPrice, for: UIControl.State.normal)
            
            raffleCell.sellTicketButton.setTitle("Sell ticket-" + String(indexPath.row + 1), for: UIControl.State.normal)
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

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let marginRaffle = marginRaffles[indexPath.row]
        
        // MARK: Compare the current time and the raffle start time
        
        // Get current time
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYYMMddHHmm"
        let currentTime = dateformatter.string(from: Date())
        
        // get the raffle start time
        let startYear = marginRaffle.startDate.split(separator: "/")[2]
        let startMonth = marginRaffle.startDate.split(separator: "/")[1]
        let startDay = marginRaffle.startDate.split(separator: "/")[0]
        let startHour = marginRaffle.startTime.split(separator: ":")[0]
        let startMinute = marginRaffle.startTime.split(separator: ":")[1]
        
        // change the startTime format (same as the format of currentTime),
        // so we can compare the currentTime and startTime
        let marginStartTime = startYear + startMonth + startDay + startHour + startMinute
        
        if editingStyle == .delete {
            
            // Compare the currentTime and raffleStartTime.
            if (currentTime < marginStartTime) {
                database.deleteQueryByID(tableName: "MarginRaffle", id: Int(marginRaffle.ID))
                
                // delete all tickets reletes to this raffle.
                database.deleteByName(tableName: "MarginTicket", raffleName: marginRaffle.raffleName)
                
                marginRaffles.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                print("\(marginRaffle.raffleName) record has deleted.")
                
            } else {
                print("You can't not delete this raffle since this raffle have been started.")
            }
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
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "addMargin" {
            print("Add a new raffle here.")
        
        } else if segue.identifier == "showMarginDetail" {
            // pass all value to the raffleDetailViewContorller.
            
            print("Show margin raffle details.")
            
            guard let detailViewController = segue.destination as? marginDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // Work out which cell in the TableView was tapped
            guard  let selectedRaffleCell = sender as? marginTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedRaffleCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMargin = marginRaffles[indexPath.row]
            detailViewController.marginRaffle = selectedMargin
            
        } else if segue.identifier == "SellMarginTicket" {
            
            guard let ticketViewController = segue.destination as? marginTicketTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard  let selectedButton = sender as? UIButton else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            print("Sell a margin ticket here~~")
            
            database.createMarginTicketTable()
            
            // get the cell row number of the clicked button.
            let indexNumber = Int((selectedButton.titleLabel?.text?.split(separator: "-")[1])!)!
            
//            print("*********##@#@")
//            print(indexNumber)
            
            let indexPath = NSIndexPath(row: indexNumber - 1, section: 0)
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! marginTableViewCell
            
            let selectedMarginName = cell.raffleNameLabel.text
            let selectedStartDate = cell.startDateLabel.text
            let selectedStartTime = cell.startTimeLabel.text
            let selectedMaxNumber = cell.maxNumberButton.titleLabel?.text?.split(separator: " ")[1]
            let selectedPrice = cell.priceButton.titleLabel?.text?.split(separator: " ")[1]
            
            let selectedSoldNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM MarginTicket WHERE raffleName = '\(String(cell.raffleNameLabel.text!))';")
            
            ticketViewController.marginName = selectedMarginName!
            ticketViewController.startDate = selectedStartDate!
            ticketViewController.startTime = selectedStartTime!
            ticketViewController.ticketPrice = Int32(selectedPrice!)!
            ticketViewController.maxNumber = Int32(selectedMaxNumber!)!
            
            ticketViewController.soldNumber = selectedSoldNumber
        
        } else if segue.identifier == "selectMarginWinnerSegue" {
            
            guard let selectMarginWinnerView = segue.destination as? marginWinnerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard  let selectedButton = sender as? UIButton else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            // get the cell row number of the clicked button.
            let indexNumber = Int((selectedButton.titleLabel?.text?.split(separator: " ")[3])!)!
                        
            let indexPath = NSIndexPath(row: indexNumber - 1, section: 0)
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! marginTableViewCell
            
            let selectedMarginName = cell.raffleNameLabel.text
            let selecteddMarginTotalNumber = cell.maxNumberButton.titleLabel?.text?.split(separator: " ")[1]
            let selectedMarginSoldNumber = cell.soldButton.titleLabel?.text?.split(separator: " ")[1]
            
            selectMarginWinnerView.marginName = selectedMarginName!
            selectMarginWinnerView.maxNumber = Int32(selecteddMarginTotalNumber!)!
            selectMarginWinnerView.soldNumber = Int32(selectedMarginSoldNumber!)!
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func unwindToMarginList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? marginDetailViewController, let marginRaffle = sourceViewController.marginRaffle {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing raffle
                marginRaffles[selectedIndexPath.row] = marginRaffle
                
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
                database.updateQuery(updateQueryStatement: "UPDATE MarginRaffle SET raffleName = '\(marginRaffle.raffleName)', prize = \(marginRaffle.prize), price = \(marginRaffle.price), maxNumber = \(marginRaffle.maxNumberOfRaffle), startTime = '\(marginRaffle.startTime)', startDate = '\(marginRaffle.startDate)' WHERE startTime = '\(marginRaffle.startTime)' and startDate = '\(marginRaffle.startDate)';")
                
                database.updateQuery(updateQueryStatement: "UPDATE MarginTicket SET raffleName = '\(marginRaffle.raffleName)' WHERE startTime = '\(marginRaffle.startTime)' and startDate = '\(marginRaffle.startDate)';")
                
                print("Update an existing margin raffle")
                
            } else {
                // Add a new raffle here
                let newIndexPath = IndexPath(row: marginRaffles.count, section: 0)
                
                marginRaffles.append(marginRaffle)
                
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                database.insert(marginRaffle: MarginRaffle(
                    raffleName: marginRaffle.raffleName,
                    prize: marginRaffle.prize,
                    price: marginRaffle.price,
                    startDate: marginRaffle.startDate,
                    startTime: marginRaffle.startTime,
                    maxNumberOfRaffle: marginRaffle.maxNumberOfRaffle)
                )
                
                print(database.selectAllMargins())
                print("Adding a new margin raffle")
            }
        }
    }

    
    // MARK: Private Methods
       
    private func loadRafflesData() {
        marginRaffles = database.selectAllMargins()
    }
}

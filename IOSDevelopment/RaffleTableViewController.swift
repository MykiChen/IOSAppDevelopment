//
//  RaffleTableViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/21.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class RaffleTableViewController: UITableViewController {
    
    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    
    // MARK: Initialization
    
    var raffles = [Raffle]()
    var raffleImages = [RaffleImage]()
    
    var pickedImageURL: URL?
    var savedImageFilename = ""
    
    var id: Int32 = 0
    var raffleName: String = "Lucky1"
    var startDate: String = "01/01/2020"
    var startTime: String = "00:00"
    var ticketPrice: Int = 6
    var maxNumber: Int = 0
    var soldNumber: Int = 0
    
    override func viewDidLoad() {
                
        super.viewDidLoad()
        
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RaffleTableViewCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.tableView.setEditing(false, animated: true)
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        loadRafflesData()
                
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return raffles.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // The withIdentifier value tells the table which prototype cell layout use
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RaffleTableViewCell", for: indexPath)
        
        let raffle = raffles[indexPath.row]
//        let raffleImage = raffleImages[indexPath.row]
        
        if let raffleCell = cell as? RaffleTableViewCell {
            raffleCell.raffleNameLabel.text = raffle.raffleName
            raffleCell.prizeLabel.text = String(raffle.prize)
            raffleCell.startTimeLabel.text = raffle.startTime
            raffleCell.startDateLabel.text = raffle.startDate
            raffleCell.startTimeLabel.text = raffle.startTime
            raffleCell.startDateLabel.text = raffle.startDate
            raffleCell.maxNumberLabel.text = String(raffle.maxNumberOfRaffle)
            raffleCell.ticketPriceLabel.text = String(raffle.ticketPrice)
            
            // Load the raffle image name from database
            let raffleImage = database.selectimageBy(name: raffleCell.raffleNameLabel.text!)
            let raffleImageName = raffleImage?[0].imageName
                        
            if (raffleImageName != "" && raffleImageName != nil) {
                // Transfer the image name to filepath.
                let filepath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + raffleImageName!
            
                raffleCell.raffleImageView.contentMode = .scaleAspectFit
                raffleCell.raffleImageView.image = UIImage(contentsOfFile: filepath)
            }
            
            // get the total number of sold ticket for this raffle
            let cellSoldNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM Ticket WHERE raffleName = '\(raffle.raffleName)';")

            raffleCell.soldNumberLabel.text = String(cellSoldNumber)
            
            raffleCell.getTicketButton.setTitle("Selling Tickets-" + String(indexPath.row + 1), for: UIControl.State.normal)
            
            raffleCell.selectWinnerButton.setTitle("Draw a Winner " + String(indexPath.row + 1) + " >", for: UIControl.State.normal)
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
        
        // Get the deleted row's value.
        let raffle = raffles[indexPath.row]
        
        // MARK: Compare the current time and the raffle start time
        
        // Get current time
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYYMMddHHmm"
        let currentTime = dateformatter.string(from: Date())
        
        // get the raffle start time
        let startYear = raffle.startDate.split(separator: "/")[2]
        let startMonth = raffle.startDate.split(separator: "/")[1]
        let startDay = raffle.startDate.split(separator: "/")[0]
        let startHour = raffle.startTime.split(separator: ":")[0]
        let startMinute = raffle.startTime.split(separator: ":")[1]
        
        // change the startTime format (same as the format of currentTime),
        // so we can compare the currentTime and startTime
        let raffleStartTime = startYear + startMonth + startDay + startHour + startMinute
        
        if editingStyle == .delete {

            // Compare the currentTime and raffleStartTime.
            if (currentTime < raffleStartTime) {
                // delete this raffle table in the database.
                database.deleteQueryByID(tableName: "Raffle", id: Int(raffle.ID))
                // delete all tickets reletes to this raffle.
                database.deleteByName(tableName: "Ticket", raffleName: raffle.raffleName)
                database.deleteByName(tableName: "RaffleImage", raffleName: raffle.raffleName)
                
                // Remove this row in the table
                raffles.remove(at: indexPath.row)
                
                // loadRafflesData()
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                print("\(raffle.raffleName) record has deleted.")
                
            } else {
                print("You can't not delete this raffle since this raffle have been started.")
            }

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: Actions
    
    @IBAction func unwindToRaffleList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? raffleDetailViewController, let raffle = sourceViewController.raffle {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing raffle
                raffles[selectedIndexPath.row] = raffle
                
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
                database.updateQuery(updateQueryStatement: "UPDATE Raffle SET raffleName = '\(raffle.raffleName)', prize = \(raffle.prize), ticketPrice = \(raffle.ticketPrice), maxNumberOfRaffle = \(raffle.maxNumberOfRaffle), startTime = '\(raffle.startTime)', startDate = '\(raffle.startDate)', description = '\(raffle.description)' WHERE startTime = '\(raffle.startTime)' and startDate = '\(raffle.startDate)';")
                
                database.updateQuery(updateQueryStatement: "UPDATE Ticket SET raffleName = '\(raffle.raffleName)', ticketPrice = \(raffle.ticketPrice) WHERE startTime = '\(raffle.startTime)' and startDate = '\(raffle.startDate)';")
                
                
                print("Update an existing raffle")
                
            } else {
                // Add a new raffle here
                let newIndexPath = IndexPath(row: raffles.count, section: 0)
                
                raffles.append(raffle)
                
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                database.insert(raffle: Raffle(
                    raffleName: raffle.raffleName,
                    prize: raffle.prize,
                    ticketPrice: raffle.ticketPrice,
                    maxNumberOfRaffle: raffle.maxNumberOfRaffle,
                    startTime: raffle.startTime,
                    startDate: raffle.startDate,
                    description: raffle.description)
                )
                
                // Load the raffle image name from database
//                let raffleImage = savedImageFilename
//                let raffleImageName = (raffleImage?[0].imageName)!
//
//                database.insert(raffleImage: RaffleImage(raffleName: raffle.raffleName, imageName: raffleImageName))
                
//                print(database.selectAllRaffles())
                print("Adding a new raffle")
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "AddRaffle" {
            print("Add a new raffle here.")
            
        } else if segue.identifier == "showRaffleDetail" {
            
            // pass all value to the raffleDetailViewContorller.
            
            guard let detailViewController = segue.destination as? raffleDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // Work out which cell in the TableView was tapped
            guard  let selectedRaffleCell = sender as? RaffleTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedRaffleCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedRaffle = raffles[indexPath.row]
//            let selectedRaffleImage = raffleImages[indexPath.row]
//            detailViewController.raffleImage = selectedRaffleImage
            detailViewController.raffle = selectedRaffle
                        
        } else if segue.identifier == "getTicketSegue" {
            
            guard let ticketViewController = segue.destination as? TicketTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard  let selectedButton = sender as? UIButton else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            database.createTicketTable()

            // get the cell row number of the clicked button.
            let indexNumber = Int((selectedButton.titleLabel?.text?.split(separator: "-")[1])!)!
            
            let indexPath = NSIndexPath(row: indexNumber - 1, section: 0)
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! RaffleTableViewCell

            let selectedRaffleName = cell.raffleNameLabel.text
            let selectedStartDate = cell.startDateLabel.text
            let selectedStartTime = cell.startTimeLabel.text
            let selectedPrice = cell.ticketPriceLabel.text
            let selectedMaxNumber = cell.maxNumberLabel.text
            
            let selectedSoldNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM Ticket WHERE raffleName = '\(String(cell.raffleNameLabel.text!))';")
            
            // pass the value to next screen view.
            ticketViewController.raffleName = selectedRaffleName!
            ticketViewController.startTime = selectedStartTime!
            ticketViewController.startDate = selectedStartDate!
            ticketViewController.maxNumber = Int32(selectedMaxNumber!)!
            ticketViewController.ticketPrice = Int(selectedPrice!)!
            
            ticketViewController.soldNumber = selectedSoldNumber

        } else if segue.identifier == "selectWinnerSegue" {
            
            guard let ticketViewController = segue.destination as? raffleWinnerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard  let selectedButton = sender as? UIButton else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            // get the cell row number of the clicked button.
            let indexNumber = Int((selectedButton.titleLabel?.text?.split(separator: " ")[3])!)!
            
            let indexPath = NSIndexPath(row: indexNumber - 1, section: 0)
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! RaffleTableViewCell
            
            let selectedRaffleName = cell.raffleNameLabel.text
            let selectedMaxNumber = cell.maxNumberLabel.text
            let selectedSoldNumber = cell.soldNumberLabel.text
            
            // pass the value to next screen view.
            ticketViewController.raffleName = selectedRaffleName!
            ticketViewController.maxNumber = Int32(selectedMaxNumber!)!
            ticketViewController.soldNumber = Int32(selectedSoldNumber!)!
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
    
    
    // MARK: Private Methods
       
    private func loadRafflesData() {
        raffles = database.selectAllRaffles()
    }
}

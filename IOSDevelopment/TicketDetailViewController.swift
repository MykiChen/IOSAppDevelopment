//
//  TicketDetailViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/22.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class TicketDetailViewController: UIViewController, UITextFieldDelegate {

    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    var ticket : Ticket?
    
//    var raffle : Raffle?
    var soldNumber: Int32 = 0
    var maxNumber: Int32 = 0
    
    var purchaseTime: String = ""
    var purchaseDate: String = ""
    var ticketPrice: String = ""
    var startDate: String = "01/02/1991"
    var startTime: String = "12:12"
    var NoTicket: Int = 100000
    var singleTicket: String = "Single"
    var raffleName: String = ""
    
    
    // MARK: Properties
    
    @IBOutlet weak var raffleNameLabel: UILabel!
    @IBOutlet weak var purchaseDateLabel: UILabel!
    @IBOutlet weak var purchaseTimeLabel: UILabel!
    @IBOutlet weak var singleLable: UILabel!
    @IBOutlet weak var ticketNumberText: UITextField!
    @IBOutlet weak var customerName: UITextField!
    @IBOutlet weak var ticketPriceLabel: UILabel!
    @IBOutlet weak var NoTicketLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var errorMessageText: UILabel!
    @IBOutlet weak var errorMessageText2: UILabel!
    @IBOutlet weak var errorImage: UIImageView!
    
    @IBOutlet weak var saveTicketButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorImage.image = UIImage(named: "None")
        
        customerName.delegate = self

        initilizeData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
                
        guard let button = sender as? UIBarButtonItem, button === saveTicketButton else {
            
            print("The save ticket button was not pressed.")
            return
        }
        
        let raffleName = raffleNameLabel.text ?? ""
        let ticketNumber = ticketNumberText.text ?? ""
        let purchaseDate = purchaseDateLabel.text ?? ""
        let purchaseTime = purchaseTimeLabel.text ?? ""
        let singleTicket = singleLable.text ?? ""
        let customername = customerName.text ?? ""
        let NoTicket = NoTicketLabel.text ?? ""
        let ticketPrice = ticketPriceLabel.text ?? ""
        let startDate = startDateLabel.text ?? ""
        let startTime = startTimeLabel.text ?? ""
        
        guard let tikcetnumber = Int32(ticketNumber) else {
            errorImage.image = UIImage(named: "error")
            errorMessageText.text = "Sorry, \(ticketNumberText.text!) is not a digit numbe."
            errorMessageText2.text = "You should choose another ticket number."
            saveTicketButton.isEnabled = false
            
            return
        }
        
        // Set the ticket to be passed to TicketTableViewController after the unwind segue.
        ticket = Ticket(raffleName: raffleName, ticketNumber: tikcetnumber, ticketPrice: Int32(ticketPrice)!, purchaseTime: purchaseTime, purchaseDate: purchaseDate, startDate: startDate, startTime: startTime, NoTicket: NoTicket, customerName: customername, singleTicket: singleTicket)
        
        print("\(raffleName) is changed.")
    }
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        saveTicketButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        updateSaveButtonState()
        navigationItem.title = raffleNameLabel.text
        
    }
    
    
    // MARK: - Actions
    
    
    
    @IBAction func cencelButton(_ sender: UIBarButtonItem) {
        
        let isPresentingInAddRaffleMode = presentingViewController is UINavigationController
        
        if isPresentingInAddRaffleMode {
            dismiss(animated: true, completion: nil)
            
        } else if let owningNavigationController = navigationController {
            
            owningNavigationController.popViewController(animated: true)
            
        } else {
            fatalError("The raffleDetailViewContorller is not inside a navigation controller.")
        }
    }
    
    private func updateSaveButtonState() {
        
        guard let tikcetnumber = Int32(ticketNumberText.text!) else {
            errorImage.image = UIImage(named: "error")
            errorMessageText.text = "Sorry, \(ticketNumberText.text!) is not a digit numbe."
            errorMessageText2.text = "You should choose another ticket number."
            saveTicketButton.isEnabled = false
            
            return
        }
        
        // Check the ticket number in sqlite3 database.
        let countNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM Ticket WHERE ticketNumber = \(String(tikcetnumber))")
        
        if countNumber > 0 {
            errorImage.image = UIImage(named: "error")
            errorMessageText.text = "Sorry, the ticket number \(ticketNumberText.text!) has sold."
            errorMessageText2.text = "You should choose another ticket number."
            
            saveTicketButton.isEnabled = false
            
        } else {
            errorMessageText.text = ""
            errorImage.image = UIImage(named: "None")
            errorMessageText2.text = ""
            
            // Disable the Save button if the text field is empty
            let name = customerName.text ?? ""
            let ticketNumber = ticketNumberText.text ?? ""
            
            saveTicketButton.isEnabled = !name.isEmpty && !ticketNumber.isEmpty
        }
    }
    
    private func initilizeData() {
        errorImage.image = UIImage(named: "None")
        
        customerName.delegate = self

        // Do any additional setup after loading the view.
        if let displayTicket = ticket {
            raffleNameLabel.text = displayTicket.raffleName
            purchaseDateLabel.text = displayTicket.purchaseDate
            purchaseTimeLabel.text = displayTicket.purchaseTime
            startDateLabel.text = displayTicket.startDate
            startTimeLabel.text = displayTicket.startTime
            singleLable.text = displayTicket.singleTicket
            ticketNumberText.text = String(displayTicket.ticketNumber)
            customerName.text = displayTicket.customerName
            NoTicketLabel.text = displayTicket.NoTicket
            ticketPriceLabel.text = String(displayTicket.ticketPrice)
        }
        
        self.raffleNameLabel.text = raffleName
        self.purchaseTimeLabel.text = purchaseTime
        self.purchaseDateLabel.text = purchaseDate
        
        self.ticketPriceLabel.text = ticketPrice
        self.startDateLabel.text = startDate
        self.startTimeLabel.text = startTime
        
        self.NoTicketLabel.text = String(NoTicket)
    }

}

//
//  addMarginTicketViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/25.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class addMarginTicketViewController: UIViewController, UITextFieldDelegate {

    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    
    var marginTicket: MarginTicket?
    
    
    // MARK: - Properties
    
    var marginName: String = ""
    var sDate: String = ""
    var sTime: String = ""
    var price: Int32 = 0
    var cName: String = ""
    var purchaseTime: String = ""
    var purchaseDate: String = ""
    var maxNumber: Int32 = 10
    var randomnumber: Int32 = 0
    
    @IBOutlet weak var raffleNameLabel: UILabel!
    @IBOutlet weak var randomNumber: UILabel!
    @IBOutlet weak var customerName: UITextField!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var purchaseTimeLabel: UILabel!
    @IBOutlet weak var purchaseDateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerName.delegate = self
        
        // generate a random number between 0 and the max number
        var randomnumber = Int32(arc4random() % UInt32(maxNumber))
        
        var count = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM MarginTicket WHERE ticketNumber = \(randomnumber) and raffleName = '\(marginName)'")
        
        while (count >= 1) {
            // re-generate a random number between 0 and the max number
            randomnumber = Int32(arc4random() % UInt32(maxNumber))
            print("Re-generate a random number")
            
            count = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM MarginTicket WHERE ticketNumber = \(randomnumber) and raffleName = '\(marginName)'")
            
            if ( count <= 0 ) {
                break
            }
        }
        
        let stringRandomNumber = String(format: "%03d", randomnumber)
        
        // Do any additional setup after loading the view.
        if let displayTicket = marginTicket {
            raffleNameLabel.text = displayTicket.raffleName
            randomNumber.text = stringRandomNumber
            purchaseDateLabel.text = displayTicket.purchaseDate
            purchaseTimeLabel.text = displayTicket.purchaseTime
            priceLabel.text = String(displayTicket.price)
            startDate.text = displayTicket.startDate
            startTime.text = displayTicket.startTime
        }
        
        self.raffleNameLabel.text = marginName
        self.randomNumber.text = stringRandomNumber
        self.purchaseTimeLabel.text = purchaseTime
        self.purchaseDateLabel.text = purchaseDate
        self.startDate.text = sDate
        self.startTime.text = sTime
        self.priceLabel.text = String(price)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            print("The save ticket button was not pressed.")
            return
        }
        
        let marginName = raffleNameLabel.text ?? ""
        let ticketNumber = randomNumber.text ?? ""
        let customername = customerName.text ?? ""
        let purchaseDate = purchaseDateLabel.text ?? ""
        let purchaseTime = purchaseTimeLabel.text ?? ""
        let ticketPrice = priceLabel.text ?? ""
        let sDate = startDate.text ?? ""
        let sTime = startTime.text ?? ""
        
        marginTicket = MarginTicket(raffleName: marginName, ticketNumber: Int32(ticketNumber)!, purchaseTime: purchaseTime, purchaseDate: purchaseDate, startDate: sDate, startTime: sTime, price: Int32(ticketPrice)!, customerName: customername)

        print("\(marginName) is changed.")
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        navigationItem.title = raffleNameLabel.text
        
    }
    
    
    // MARK: - Actions
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        let isPresentingInAddRaffleMode = presentingViewController is UINavigationController
        
        if isPresentingInAddRaffleMode {
            dismiss(animated: true, completion: nil)
            
        } else if let owningNavigationController = navigationController {
            
            owningNavigationController.popViewController(animated: true)
            
        } else {
            fatalError("The marginDetailViewContorller is not inside a navigation controller.")
        }
    }
    
}

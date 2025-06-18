//
//  marginWinnerViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/26.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class marginWinnerViewController: UIViewController {
    
    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")

    var marginName: String = ""
    var maxNumber: Int32 = 0
    var soldNumber: Int32 = 0
    
    // MARK: - Properties
    
    @IBOutlet weak var marginNameLabel: UILabel!
    @IBOutlet weak var totalNumberLabel: UILabel!
    @IBOutlet weak var soldNumberLabel: UILabel!
    @IBOutlet weak var setMarginNumberText: UITextField!
    
    @IBOutlet weak var showWinnerLabel1: UILabel!
    @IBOutlet weak var showWinnerLabel2: UILabel!
    @IBOutlet weak var showWinnerLabel3: UILabel!
    @IBOutlet weak var showWinnerLabel4: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearMessage()
        initializeFormat()
    }
    
    
    @IBAction func selectWinnreButton(_ sender: UIButton) {
        
        clearMessage()
        
        guard let selectedMarginNumber = Int(setMarginNumberText.text!) else {
            showWinnerLabel1.text = "Sorry, you have to input a ticket number"
            return
        }
        
        let tickets = database.selectMarginTicketBy(ticketNumber: Int32(selectedMarginNumber))
        
        if tickets!.isEmpty {
            showWinnerLabel1.text = "Sorry, no winner for this ticket."
            
        } else {
            showWinnerLabel1.text = "Congratulation. The winner ticket number for \(marginName) is"
            showWinnerLabel2.text = String(tickets![0].ticketNumber)
            showWinnerLabel3.text = "The winner customer is: "
            showWinnerLabel4.text = tickets![0].customerName
        }

    }
    
    // MARK: - Private Methods
    
    private func clearMessage() {
        showWinnerLabel1.text = ""
        showWinnerLabel2.text = ""
        showWinnerLabel3.text = ""
        showWinnerLabel4.text = ""
    }

    private func initializeFormat() {
        marginNameLabel.text = marginName
        totalNumberLabel.text = String(maxNumber)
        soldNumberLabel.text = String(soldNumber)
        
        showWinnerLabel1.lineBreakMode = NSLineBreakMode.byWordWrapping
        showWinnerLabel1.numberOfLines = 0
        
        showWinnerLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
        showWinnerLabel2.numberOfLines = 0
        
        showWinnerLabel3.lineBreakMode = NSLineBreakMode.byWordWrapping
        showWinnerLabel3.numberOfLines = 0
        
        showWinnerLabel4.lineBreakMode = NSLineBreakMode.byWordWrapping
        showWinnerLabel4.numberOfLines = 0
    }
    
}

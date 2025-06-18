//
//  raffleWinnerViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/26.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class raffleWinnerViewController: UIViewController {

     var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    
    // MARK: - Properties
    
    var tickets = [Ticket]()
    var winners : [String] = []
    
    var raffleName: String = ""
    var maxNumber: Int32 = 0
    var soldNumber: Int32 = 0
    
    @IBOutlet weak var raffleNameLabel: UILabel!
    @IBOutlet weak var ticketNumberText: UITextField!
    @IBOutlet weak var showWinnerLabel: UILabel!
    @IBOutlet weak var showWinnerLabel2: UILabel!
    @IBOutlet weak var showWinnerLabel3: UILabel!
    @IBOutlet weak var showWinnerLabel4: UILabel!
    
    @IBOutlet weak var setWinnerNumberText: UITextField!
    
    @IBOutlet weak var totalNumberLabel: UILabel!
    @IBOutlet weak var soldNumberLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeFormat()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Methods
    
    @IBAction func selectRandomlyButton(_ sender: UIButton) {
        
        clearMessage()
        
        if (soldNumber > 0) {
            
            tickets = database.selectTicketBy(raffleName: raffleName)!
            
            let totalNumber = tickets.count
            
            // generate a random number between 0 and the max number
            let randomNumber = Int(arc4random() % UInt32(totalNumber))
//
//            print(randomNumber)
//            print(tickets[randomNumber].customerName)
//            print(tickets[randomNumber].ticketNumber)
//
            showWinnerLabel.text = "Congratulation: the winner ticket is: "
            showWinnerLabel2.text = String(tickets[randomNumber].ticketNumber)
            showWinnerLabel3.text = "The raffle winner is: "
            showWinnerLabel4.text = tickets[randomNumber].customerName
            
        } else {
            showWinnerLabel.text = "Sorry, you don't sell any ticket"
        }
    }
    
    @IBAction func selectMultiWinnerButton(_ sender: UIButton) {
        
        clearMessage()
        
        if (setWinnerNumberText.text != "" ) {
            
            guard let setWinnerNumber = Int(setWinnerNumberText.text!) else {
                showWinnerLabel.text = "You must input a digital number."
                return
            }
        
            guard setWinnerNumber > 1 else {
                showWinnerLabel.text = "The number you enter is less than 2."
                return
            }
            
            guard setWinnerNumber <= soldNumber else {
                showWinnerLabel.text = "The number you enter is beyond sold ticket number."
                return
            }
            
            if setWinnerNumberText.text == "" {
                showWinnerLabel.text = "You have to input a valid ticket number."
            }
            
            // Get all tickets from the database.
            tickets = database.selectTicketBy(raffleName: raffleName)!
            
            var totalNumber = tickets.count
            
            // Define two arrays. Randomly select from totalNumber array and put this value to the winner array
            // and delete it from totalNumber array.
            // So we can guarantee that no repeat values be choose.
            var totalNumberArr = Array(1...totalNumber)
            var winnerArr = [Int]()
            
            for _ in 1...(setWinnerNumber) {
                // generate a random number between 0 and the max number
                let randomNumber = Int(arc4random() % UInt32(totalNumber))
                
                // Add the random number to winner array
                winnerArr.append(totalNumberArr[randomNumber])
                
                // delete the random number from the totalNumber array
                totalNumberArr.remove(at: randomNumber)
                totalNumber -= 1
            }
            
            var winnerTikcts = ""
            var winnerNames = ""
            
            for i in winnerArr {
                
                winnerTikcts = "\(winnerTikcts)\(tickets[i - 1].ticketNumber), "
                winnerNames = "\(winnerNames)\(tickets[i - 1].customerName), "
            }
            
            showWinnerLabel.text = "Congratulation: The ticket numbers of winners are: "
            showWinnerLabel3.text = "The winner's names are: "
            showWinnerLabel2.text = winnerTikcts
            showWinnerLabel4.text = winnerNames
        }
    }
    
    
    @IBAction func selectManuallyButton(_ sender: UIButton) {
        
        clearMessage()
        
        guard let selectedTicketNumber = Int(ticketNumberText.text!) else {
            showWinnerLabel.text = "Sorry, you have to input a ticket number"
            return
        }
        
        tickets = database.selectTicketBy(ticketNumber: selectedTicketNumber) ?? [Ticket]()
        
        if tickets.isEmpty {
            showWinnerLabel.text = "No winner for \(selectedTicketNumber)."
        
        } else {
            showWinnerLabel.text = "Congratulation: the ticket numbers of winners are: "
            showWinnerLabel2.text = String(tickets[0].ticketNumber)
            showWinnerLabel3.text = "The winner's name is: "
            showWinnerLabel4.text = tickets[0].customerName
        }
        
    }
    
    
    private func clearMessage() {
        showWinnerLabel.text = ""
        showWinnerLabel2.text = ""
        showWinnerLabel3.text = ""
        showWinnerLabel4.text = ""
    }
    
    private func initializeFormat() {
        raffleNameLabel.text = raffleName
        totalNumberLabel.text = String(maxNumber)
        soldNumberLabel.text = String(soldNumber)
        
        showWinnerLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        showWinnerLabel.numberOfLines = 0
        
        showWinnerLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
        showWinnerLabel2.numberOfLines = 0
        
        showWinnerLabel3.lineBreakMode = NSLineBreakMode.byWordWrapping
        showWinnerLabel3.numberOfLines = 0
        
        showWinnerLabel4.lineBreakMode = NSLineBreakMode.byWordWrapping
        showWinnerLabel4.numberOfLines = 0
    }
}

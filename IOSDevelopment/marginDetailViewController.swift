//
//  marginDetailViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/25.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class marginDetailViewController: UIViewController, UITextFieldDelegate {

    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    
    // MARK: - Properties
    
    var marginRaffle: MarginRaffle?
    
    @IBOutlet weak var raffleNameText: UITextField!
    @IBOutlet weak var prizeText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var startDateText: UITextField!
    @IBOutlet weak var startTimeText: UITextField!
    @IBOutlet weak var maxNumberText: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var errorImage: UIImageView!
    @IBOutlet weak var errorMessage1: UILabel!
    @IBOutlet weak var errorMessage2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeData()
        
        if raffleNameText.text == "" {
            updateSaveButtonState()
        }
    }
    
    
    // MARK: UITextFieldDelegate
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        saveButton.isEnabled = false
//        //        updateSaveButtonState()
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        updateSaveButtonState()
        navigationItem.title = raffleNameText.text
    }
    
    
    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        let isPresentingInAddRaffleMode = presentingViewController is UINavigationController
        
        if isPresentingInAddRaffleMode {
            dismiss(animated: true, completion: nil)
            
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
            
        } else {
            fatalError("The marginDetailViewContorller is not inside a navigation controller.")
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let name = raffleNameText.text ?? ""
        let prize = prizeText.text ?? ""
        let price = priceText.text ?? ""
        let startDate = startDateText.text ?? ""
        let startTime = startTimeText.text ?? ""
        let maxNumber = maxNumberText.text ?? ""
        
        marginRaffle = MarginRaffle(raffleName: name, prize: Int32(prize) ?? 0, price: Int32(price) ?? 0, startDate: startDate, startTime: startTime, maxNumberOfRaffle: Int32(maxNumber) ?? 0)
        
        print("\(name) is changed.")
    }
    
    
    // MARK: Private Methods
    
    private func updateSaveButtonState() {
        
        // Disable the Save button if the text field is empty
        let text = raffleNameText.text ?? ""
        let prize = priceText.text ?? ""
        let price = priceText.text ?? ""
        let startDate = startDateText.text ?? ""
        let startTime = startTimeText.text ?? ""
        let maxNumber = maxNumberText.text ?? ""
        
        errorImage.image = UIImage(named: "None")
        errorMessage1.text = ""
        errorMessage2.text = ""
        
        saveButton.isEnabled = !text.isEmpty && !startDate.isEmpty && !startTime.isEmpty && !prize.isEmpty && !price.isEmpty && !maxNumber.isEmpty
        
        // Disable the button if the format of data, time are wrong
        // Or the maxNumber is less than the maxNumber.
        let selectedSoldNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM MarginTicket WHERE raffleName = '\(String(raffleNameText.text!))';")
        
        let countNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM MarginRaffle WHERE raffleName = '\(String(raffleNameText.text!))';")
        
        // Check if the sold number is less than the max number
        if (selectedSoldNumber > Int32(maxNumberText.text!) ?? 0) && maxNumberText.text != "" {
            saveButton.isEnabled = false
            errorImage.image = UIImage(named: "error")
            errorMessage1.text = "Sorry, the sold number of ticket"
            errorMessage2.text = "must less than the max number."
            
            // Check the time format and date format.
        } else if ((startTime.split(separator: ":").count) != 2) && startTimeText.text != "" {
            saveButton.isEnabled = false
            errorImage.image = UIImage(named: "error")
            errorMessage1.text = "Sorry, the start time format is wrong."
            
        } else if ((startDate.split(separator: "/").count != 3)) && startDateText.text != "" {
            saveButton.isEnabled = false
            errorImage.image = UIImage(named: "error")
            errorMessage1.text = "Sorry, the start date format is wrong."
            
        }
        else if countNumber > 0 {
            saveButton.isEnabled = false
            errorImage.image = UIImage(named: "error")
            errorMessage1.text = "Sorry, the “\(raffleNameText.text!)” has existed."
            errorMessage2.text = "You should choose another name."
        }
    }
    
    private func initializeData() {
        raffleNameText.delegate = self
        prizeText.delegate = self
        priceText.delegate = self
        startDateText.delegate = self
        startTimeText.delegate = self
        maxNumberText.delegate = self
        
        if let marginRaffle = marginRaffle {
            raffleNameText.text = marginRaffle.raffleName
            prizeText.text = String(marginRaffle.prize)
            priceText.text = String(marginRaffle.price)
            startDateText.text = marginRaffle.startDate
            startTimeText.text = marginRaffle.startTime
            maxNumberText.text = String(marginRaffle.maxNumberOfRaffle)
        }
        
    }
}

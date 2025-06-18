//
//  raffleDetailViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/21.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

extension UIImage {
    func save(as filename: String) -> String {
        let filepath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let fileurl = URL(fileURLWithPath: filepath)
            .appendingPathComponent(filename)
            .deletingPathExtension()
            .appendingPathExtension("jpeg")
        
        do {
            try self.jpegData(compressionQuality: 0.75)?.write(to: fileurl)
        }
        catch {
            print("failed to save image as JPG at \(fileurl)")
        }
        
        // return the actual filename without the path
        return fileurl.lastPathComponent
    }
}

class raffleDetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    
    var pickedImageURL: URL?
    var savedImageFilename = ""
    
    // MARK: - Properties
    
    @IBOutlet weak var raffleNameText: UITextField!
    @IBOutlet weak var prizeText: UITextField!
    @IBOutlet weak var maxTicketText: UITextField!
    @IBOutlet weak var startTimeText: UITextField!
    @IBOutlet weak var startDateText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    @IBOutlet weak var ticketPriceText: UITextField!
    
    @IBOutlet weak var raffleImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var raffle: Raffle?
    var raffleImage: RaffleImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initilizeData()
  
        updateSaveButtonState()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        updateSaveButtonState()
        navigationItem.title = raffleNameText.text
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Unable to use this image: \(info).")
        }
        
        raffleImageView.image = selectedImage
        
        pickedImageURL = (info[UIImagePickerController.InfoKey.imageURL] as? URL)!
        raffleImageView.contentMode = .scaleAspectFit
        
        if let imageUrl = pickedImageURL {
            let filename = (imageUrl.path as NSString).lastPathComponent
     
            let savedFilename = raffleImageView.image!.save(as: filename)
            
            database.insert(raffleImage: RaffleImage(raffleName: raffleNameText.text ?? "", imageName: savedFilename))
            
            if (savedFilename != "") {
                let filepath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + savedFilename
                
                raffleImageView.contentMode = .scaleAspectFit
                raffleImageView.image = UIImage(contentsOfFile: filepath)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Actions
    
    @IBAction func selectImageFromLibrary(_ sender: UITapGestureRecognizer) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            
            present(imagePickerController, animated: true, completion: nil)
            
        } else {
            errorMessageLabel.text = "No photo library available."
        }
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
            fatalError("The raffleDetailViewContorller is not inside a navigation controller.")
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
                
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let name = raffleNameText.text ?? "default"
        let prize = prizeText.text ?? "default"
        let maxNumber = maxTicketText.text ?? "default"
        let startTime = startTimeText.text ?? "default"
        let startDate = startDateText.text ?? "default"
        let description = descriptionText.text ?? "default"
        let ticketPrice = ticketPriceText.text ?? "default"
                
        raffle = Raffle(raffleName: name, prize: Int32(prize) ?? 0, ticketPrice: Int32(ticketPrice) ?? 0 , maxNumberOfRaffle: Int32(maxNumber) ?? 0, startTime: startTime, startDate: startDate, description: description)
        
        // Load the raffle image name from database
//        let raffleImageTable = database.selectimageBy(name: name)
//        let raffleImageName = raffleImageTable?[0].imageName
//        
//        if (raffleImageName != "") {
//            raffleImage = RaffleImage(raffleName: name, imageName: raffleImageName!)
//        }
        
        print("\(name) is changed.")
        
    }
    
    // MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty
        let text = raffleNameText.text ?? ""
        let startDate = startDateText.text ?? ""
        let startTime = startTimeText.text ?? ""
        let prize = prizeText.text ?? ""
        let maxNumber = maxTicketText.text ?? ""
        let ticketPrice = ticketPriceText.text ?? ""
        
        saveButton.isEnabled = !text.isEmpty && !startDate.isEmpty && !startTime.isEmpty && !prize.isEmpty && !maxNumber.isEmpty && !ticketPrice.isEmpty
        
        let selectedSoldNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM Ticket WHERE raffleName = '\(String(raffleNameText.text!))';")
                
        // Check if the sold number is less than the max number
        if (selectedSoldNumber > Int32(maxNumber) ?? 0) {
            saveButton.isEnabled = false
            errorMessageLabel.text = "Sorry, the sold number of ticket must less than the max number."
          
        // Check the time format and date format.
        } else if ((startTime.split(separator: ":").count) != 2) && startTime != "" {
            saveButton.isEnabled = false
            errorMessageLabel.text = "Sorry, the start time format is wrong."
            
        } else if ((startDate.split(separator: "/").count != 3)) && startDate != "" {
            saveButton.isEnabled = false
            errorMessageLabel.text = "Sorry, the start date format is wrong."
        } else{
            errorMessageLabel.text = ""
        }
    }
    
    
    private func initilizeData() {
        errorMessageLabel.text = ""
        errorMessageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        errorMessageLabel.numberOfLines = 0
        
        raffleNameText.delegate = self
        descriptionText.delegate = self
        startDateText.delegate = self
        startTimeText.delegate = self
        maxTicketText.delegate = self
        prizeText.delegate = self
        ticketPriceText.delegate = self
        
        if let raffle = raffle {
            raffleNameText.text = raffle.raffleName
            prizeText.text = String(raffle.prize)
            maxTicketText.text = String(raffle.maxNumberOfRaffle)
            startTimeText.text = raffle.startTime
            startDateText.text = raffle.startDate
            descriptionText.text = raffle.description
            ticketPriceText.text = String(raffle.ticketPrice)
        }
        
//        if let raffleImage = raffleImage {
//            // Load the raffle image name from database
//            let raffleImage = database.selectimageBy(name: raffleNameText.text!)
//            let raffleImageName = raffleImage?[0].imageName
//
//            if (raffleImageName != "" && raffleImageName != nil) {
//                // Transfer the image name to filepath.
//                let filepath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + raffleImageName!
//
//                raffleImageView.contentMode = .scaleAspectFit
//                raffleImageView.image = UIImage(contentsOfFile: filepath)
//            }
//        }
    }
}

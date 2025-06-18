//
//  RaffleTableViewCell.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/21.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class RaffleTableViewCell: UITableViewCell {
    
    var database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
    
    // MARK: Properties
    @IBOutlet weak var raffleNameLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var ticketPriceLabel: UILabel!
    @IBOutlet weak var alarmImageView: UIImageView!
    @IBOutlet weak var maxNumberLabel: UILabel!
    @IBOutlet weak var soldNumberLabel: UILabel!
    @IBOutlet weak var raffleImageView: UIImageView!
    
    @IBOutlet weak var getTicketButton: UIButton!
    @IBOutlet weak var selectWinnerButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: Actions
    
    @IBAction func refreshButton(_ sender: UIButton) {
        let selectedSoldNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM Ticket WHERE raffleName = '\(String(raffleNameLabel.text!))';")
        
        soldNumberLabel.text = String(selectedSoldNumber)
    }
    
    
    // Set Notification
    @IBAction func setAlarmButton(_ sender: UIButton) {
        
        // Change the alarm photo if user click "Set Notification" button
        let alarmPhoto = UIImage(named: "setAlarm")
        let noAlarm = UIImage(named: "noAlarm")
        
        // If we have set notification for this raffle
        if self.alarmImageView.image == UIImage(named: "setAlarm") {
            // Show the cancel symbol
            self.alarmImageView.image = noAlarm
            
            print("Notification has cancelled.")
            
        // If we don't set a notification before
        } else {
            self.alarmImageView.image = alarmPhoto
            
            let notificationCenter = UNUserNotificationCenter.current()
            
            notificationCenter.requestAuthorization(options: [.alert, .sound]) {
                (granted, error) in
                if (granted) {
                    
                    let content = UNMutableNotificationContent()
                    
                    content.title = "Reminder!"
                    
                    content.subtitle = "Raffle \(String(describing: self.raffleNameLabel.text!)) is ready now!"
                    content.body = "Check the winners for \(String(describing: self.raffleNameLabel.text!))"
                    
                    content.badge = 4
                    //                content.sound = UNNotificationSound?
                    
                    var dateInfo = DateComponents()
                    
                    let time = self.startTimeLabel.text!.split(separator: ":")
//                    print(time)
                    
                    let date = self.startDateLabel.text!.split(separator: "/")
//                    print(date)
                    
                    dateInfo.year = Int(date[2])
                    dateInfo.month = Int(date[1])
                    dateInfo.day = Int(date[0])
                    dateInfo.hour = Int(time[0])
                    dateInfo.minute = Int(time[1])
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: "Raffle Notification", content: content, trigger: trigger)
                    
                    notificationCenter.add(request) { (error: Error?) in
                        if let theError = error {
                            print(theError.localizedDescription)
                        }
                    }
                
                    print("The notificaiton time for raffle is: \(self.startDateLabel.text!), \(self.startTimeLabel.text!)")
                    print("Set notification succeed!")
                }
            }
        }
    }
}

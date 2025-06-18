//
//  TicketTableViewCell.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/22.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class TicketTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    var raffle: Raffle?
    
    @IBOutlet weak var raffleName: UILabel!
    @IBOutlet weak var purchaseDate: UILabel!
    @IBOutlet weak var purchaseTime: UILabel!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var ticketNumber: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var ticketPrice: UILabel!
    @IBOutlet weak var NoTicket: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var startTime: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        if let raffle = raffle {
            raffleName.text = raffle.raffleName
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Actions
    
    @IBAction func shareButton(_ sender: UIButton) {
        let shareViewController = UIActivityViewController(activityItems: ["I'm \(customerName.text ?? ""), ticket \(ticketNumber.text ?? ""), $ \(ticketPrice.text ?? "10"), purchased at: \(purchaseDate.text ?? "") \(purchaseTime.text ?? "")"], applicationActivities: [])
        
        shareViewController.excludedActivityTypes = [UIActivity.ActivityType.postToTwitter, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.airDrop]
        
        self.window?.rootViewController!.present(shareViewController, animated: true, completion: nil)
    }
    
}

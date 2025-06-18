//
//  marginTableViewCell.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/25.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class marginTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var raffleNameLabel: UILabel!
    @IBOutlet weak var maxNumberButton: UIButton!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var sellTicketButton: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var selectWinnerButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Refresh the sold number when we click the button.
    @IBAction func refreshButton(_ sender: UIButton) {
        let database : SQLiteDatabase = SQLiteDatabase(databaseName:"MyDatabase")
        
        let soldNumber = database.selectCountQuery(selectCountQueryStatement: "SELECT * FROM MarginTicket WHERE raffleName = '\(raffleNameLabel.text!)';")
        
        let soldButtonText = " Sold: \(String(soldNumber))"

        soldButton.setTitle(soldButtonText, for: UIControl.State.normal)
        
    }

}

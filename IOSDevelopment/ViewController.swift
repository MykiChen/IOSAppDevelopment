//
//  ViewController.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/21.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let database: SQLiteDatabase = SQLiteDatabase(databaseName: "MyDatabase")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        print(database.selectAllRaffles())
        
    }


}


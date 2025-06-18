//
//  Raffle.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/21.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import Foundation

public struct Raffle {
    var ID: Int32 = -1
    var raffleName: String
//    var imageURL: URL
    var prize: Int32
    var ticketPrice: Int32
    var maxNumberOfRaffle: Int32
    var startTime: String
    var startDate: String
    var description: String
}

public struct RaffleImage {
    var ID: Int32 = -1
    var raffleName: String
    var imageName: String
}

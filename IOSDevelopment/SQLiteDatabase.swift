//
//  SQLiteDatabase.swift
//  kit607Assignment2
//
//  Created by Myki on 2020/4/21.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteDatabase {
    
    //   In computer programming, an opaque pointer is a special case of an opaque data type,
    //   a data type declared to be a pointer to a record or data structure of some unspecified type.

    /* This variable is of type OpaquePointer, which is effectively the same as a C pointer (recall the SQLite API is a C-library). The variable is declared as an optional, since it is possible that a database connection is not made successfully, and will be nil until such time as we create the connection.*/
    private var db: OpaquePointer?
    
    private let DATABASE_VERSION = 28
    
    init(databaseName dbName: String) {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(dbName).sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(fileURL.path)")
            checkForUpgrade();
        } else {
            print("Unable to open database at \(fileURL.path)")
            printCurrentSQLErrorMessage(db)
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    private func printCurrentSQLErrorMessage(_ db: OpaquePointer?) {
        let errorMessage = String.init(cString: sqlite3_errmsg(db))
        print("Error: \(errorMessage)")
    }
    
    private func createTables() {
        createRaffleTable()
        createTicketTable()
        createMarginTable()
        createMarginTicketTable()
        createRaffleImageTable()
    }
    
    private func dropTables() {
        dropTable(tableName: "Raffle")
        dropTable(tableName: "Ticket")
        dropTable(tableName: "MarginRaffle")
        dropTable(tableName: "MarginTicket")
        dropTable(tableName: "RaffleImage")
    }
    
    /* --------------------------------*/
    /* ----- VERSIONING FUNCTIONS -----*/
    /* --------------------------------*/
    func checkForUpgrade() {
        let defaults = UserDefaults.standard
        let lastSavedVersion = defaults.integer(forKey: "DATABASE_VERSION")
        
        // detect a version change
        if (DATABASE_VERSION > lastSavedVersion) {
            onUpdateDatabase(previousVersion:lastSavedVersion, newVersion: DATABASE_VERSION);
            
            defaults.set(DATABASE_VERSION, forKey: "DATABASE_VERSION")
        }
    }
    
    func onUpdateDatabase(previousVersion : Int, newVersion : Int) {
        print("Detected Database Version Change (was: \(previousVersion), now: \(newVersion))")
        
        dropTables()
        createTables()
    }
    
    /* --------------------------------*/
    /* ------- HELPER FUNCTIONS -------*/
    /* --------------------------------*/
    
    /* Pass this function a CREATE sql string, and a table name, and it will create a table
        You should call this function from createTables()
     */
    
    private func createTableWithQuery(_ createTableQuery: String, tableName: String) {
        /*
         1.    sqlite3_prepare_v2()
         2.    sqlite3_step()
         3.    sqlite3_finalize()
         */
        
        //prepare the statement
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK {
            // execute the statement
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("\(tableName) talbe created.")
            } else {
                print("\(tableName) table could not be created.")
                printCurrentSQLErrorMessage(db)
            }
        } else {
            print("CREATE TABLE statement for \(tableName) could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        
        // Clean up
        sqlite3_finalize(createTableStatement)
    }
    
    private func dropTable(tableName: String) {
        let query = "DROP TABLE IF EXISTS \(tableName)"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // Run the query
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(tableName) table deleted.")
            }
        } else {
            print("\(tableName) table could not be deleted.")
            printCurrentSQLErrorMessage(db)
        }
        
        // Clean up
        sqlite3_finalize(statement)
    }
    
    //helper function for handling INSERT statements
    //provide it with a binding function for replacing the ?'s for setting values
    private func insertWithQuery(_ insertStatementQuery: String, bindingFunction: (
        _ insertStatement: OpaquePointer?) -> ()) {
        /*
         Similar to the CREATE statement, the INSERT statement needs the following SQLite functions to be called (note the addition of the binding function calls):
         1.    sqlite3_prepare_v2()
         2.    sqlite3_bind_***()
         3.    sqlite3_step()
         4.    sqlite3_finalize()
         */
        // First, we prepare the statement, and check that this was successful. The result will be a C-
        // pointer to the statement:
        var insertStatement: OpaquePointer? =  nil
        if sqlite3_prepare_v2(db, insertStatementQuery, -1, &insertStatement, nil) == SQLITE_OK {
            bindingFunction(insertStatement)
            
            /* Using the pointer to the statement, we can call the sqlite3_step() function. Again, we only
             step once. We check that this was successful */
            //execute the statement
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
                printCurrentSQLErrorMessage(db)
            }
        } else {
            print("INSERT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        
        // Clean up
        sqlite3_finalize(insertStatement)
    }
    
    private func selectWithQuery(
        _ selectStatementQuery: String,
        eachRow: (_ rowHandle: OpaquePointer?) -> (),
        bindingFunction: ((_ rowHandle: OpaquePointer?) -> ())? = nil) {
        // Prepare the statement
        var selectStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectStatementQuery, -1, &selectStatement, nil) == SQLITE_OK {
            // do bindings, only if we have a bindingFunction set hint,
            bindingFunction?(selectStatement)
            
            // Iterate over the result
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                eachRow(selectStatement)
            }
        } else {
            print("SELECT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        
        // Clean up
        sqlite3_finalize(selectStatement)
    }
    
    // helper function to run update statements.
    func updateWithQuery(
        _ updateStatementQuery: String, bindingFunction: ((_ rowHandle: OpaquePointer?) -> ())) {
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementQuery, -1, &updateStatement, nil) == SQLITE_OK {
            
            // do bindings
            bindingFunction(updateStatement)
            
            // execute
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully update row.")
            } else {
                print("Could not insert row.")
                printCurrentSQLErrorMessage(db)
            }
        } else {
            print("UPDATE statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        
        // clean up
        sqlite3_finalize(updateStatement)
    }
    
    
    /* --------------------------------*/
    /* --- ADD YOUR TABLES ETC HERE ---*/
    /* --------------------------------*/
    
    func createRaffleTable() {
        let createRafflesTableQuery = """
            CREATE TABLE Raffle (
                ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                raffleName CHAR(255),
                prize INTERGER,
                ticketPrice INTERGER,
                maxNumberOfRaffle INTERGER,
                startTime CHAR(255),
                startDate CHAR(255),
                description CHAR(255)
        );
    """
        createTableWithQuery(createRafflesTableQuery, tableName: "RaffleImage")
    }
    
    func createRaffleImageTable() {
        let createRafflesTableQuery = """
            CREATE TABLE RaffleImage (
                ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                raffleName CHAR(255),
                imageName CHAR(255)
        );
    """
        createTableWithQuery(createRafflesTableQuery, tableName: "RaffleImage")
    }
    
    func selectimageBy(name: String) -> [RaffleImage]? {
        var result: RaffleImage?
        let selectStatementQuery = "SELECT id, raffleName, imageName FROM RaffleImage WHERE raffleName = '\(name)'"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let raffleImage = RaffleImage(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                imageName: String(cString: sqlite3_column_text(row, 2))
            )
            result = raffleImage
        })
        if (result != nil) {
            return [result!]
            
        } else {
            return nil
        }
    }
    
    func insert(raffleImage: RaffleImage) {
        let insertStatementQuery = "INSERT INTO RaffleImage(raffleName, imageName) VALUES (?, ?);"
        
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string: raffleImage.raffleName).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, NSString(string: raffleImage.imageName).utf8String, -1, nil)
        })
    }
    
    func insert(raffle: Raffle) {
        let insertStatementQuery = "INSERT INTO Raffle(raffleName, prize, ticketPrice, maxNumberOfRaffle, startTime, startDate, description) VALUES (?, ?, ?, ?, ?, ?, ?);"
        
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string: raffle.raffleName).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, raffle.prize)
            sqlite3_bind_int(insertStatement, 3, raffle.ticketPrice)
            sqlite3_bind_int(insertStatement, 4, raffle.maxNumberOfRaffle)
            sqlite3_bind_text(insertStatement, 5, NSString(string: raffle.startTime).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, NSString(string: raffle.startDate).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, NSString(string: raffle.description).utf8String, -1, nil)
        })
    }
    
    func selectAllRaffles() -> [Raffle] {
        
        var result = [Raffle]()
        
        let selectStatementQuery = "SELECT id, raffleName, prize, ticketPrice, maxNumberOfRaffle, startTime, startDate, description FROM Raffle;"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let raffle = Raffle(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                prize: sqlite3_column_int(row, 2),
                ticketPrice: sqlite3_column_int(row, 3),
                maxNumberOfRaffle: sqlite3_column_int(row, 4),
                startTime: String(cString: sqlite3_column_text(row, 5)),
                startDate: String(cString: sqlite3_column_text(row, 6)),
                description: String(cString: sqlite3_column_text(row, 7))
            )
            result += [raffle]
        })
        return result
    }
    
//    func selectCountRaffles() -> Int32? {
//        
//        var result: Int32 = 0
//        
//        let selectStatementQuery = "SELECT COUNT * FROM Raffle;"
//        
//        selectWithQuery(selectStatementQuery, eachRow: { (row) in
//            let raffle = Raffle(
//                ID: sqlite3_column_int(row, 0),
//                raffleName: String(cString: sqlite3_column_text(row, 1)),
//                prize: sqlite3_column_int(row, 2),
//                maxNumberOfRaffle: sqlite3_column_int(row, 3),
//                startTime: String(cString: sqlite3_column_text(row, 4)),
//                startDate: String(cString: sqlite3_column_text(row, 5)),
//                description: String(cString: sqlite3_column_text(row, 6))
//            )
//            result = result + 1
//        })
//        return result
//    }
    
    func selectRaffleBy(name: String) -> [Raffle]? {
        var result: Raffle?
        let selectStatementQuery = "SELECT id, raffleName, prize, ticketPrice, maxNumberOfRaffle, startTime, startDate, description FROM Raffle WHERE raffleName = '\(name)'"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let raffle = Raffle(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                prize: sqlite3_column_int(row, 2),
                ticketPrice: sqlite3_column_int(row, 3),
                maxNumberOfRaffle: sqlite3_column_int(row, 4),
                startTime: String(cString: sqlite3_column_text(row, 5)),
                startDate: String(cString: sqlite3_column_text(row, 6)),
                description: String(cString: sqlite3_column_text(row, 7))
            )
            result = raffle
        })
        if (result != nil) {
            return [result!]
        } else {
            return nil
        }
    }
    
    
    func selectRaffleBy(id: Int32) -> [Raffle]? {
        var result: Raffle?
        let selectStatementQuery = "SELECT id, raffleName, prize, ticketPrice, maxNumberOfRaffle, startTime, startDate, description FROM Raffle WHERE id = \(id)"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let raffle = Raffle(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                prize: sqlite3_column_int(row, 2),
                ticketPrice: sqlite3_column_int(row, 3),
                maxNumberOfRaffle: sqlite3_column_int(row, 4),
                startTime: String(cString: sqlite3_column_text(row, 5)),
                startDate: String(cString: sqlite3_column_text(row, 6)),
                description: String(cString: sqlite3_column_text(row, 7))
            )
            result = raffle
        })
        if (result != nil) {
            return [result!]
        } else {
            return nil
        }
    
    }
    
    
    func deleteTable(tableName: String) {
        let query = "DELETE FROM \(tableName)"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // run the query
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(tableName) table deleted.")
            }
        } else {
            print("\(tableName) table could not be deleted.")
            printCurrentSQLErrorMessage(db)
        }
        
        // Clean up
        sqlite3_finalize(statement)
    }
    
    func deleteQueryByID(tableName: String, id: Int) {
        // prepare the statement
        let query = "DELETE FROM \(tableName) WHERE ID = \(id)"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // run the query
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(tableName) table record: id = \(id) is deleted.")
            }
        } else {
            print("\(tableName) talbe could not be deleted.")
            printCurrentSQLErrorMessage(db)
        }
        
        // Clean up
        sqlite3_finalize(statement)
    }
    
    
    func updateQuery(updateQueryStatement: String) {
        // prepare the statement
        let query = updateQueryStatement
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // run the query
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Table updated.")
            }
        } else {
            print("Table could not be updated.")
            printCurrentSQLErrorMessage(db)
        }
        
        // Clean up
        sqlite3_finalize(statement)
    }
    
    func selectCountQuery(selectCountQueryStatement: String) -> Int32 {
        // prepare the statement
        let query = selectCountQueryStatement
        var statement: OpaquePointer? = nil
        var columns: Int32 = 0
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // run the query
            while sqlite3_step(statement) == SQLITE_ROW {
                columns += 1
            }
        } else {
            print("Table could not be counted.")
            printCurrentSQLErrorMessage(db)
        }
        
        // Clean up
        sqlite3_finalize(statement)
        
        return Int32(columns)
    }
    
    /* --------------------------------*/
    /* ------- FOR TICKET TABLE -------*/
    /* --------------------------------*/
    
    func createTicketTable() {
//        dropTable(tableName: "Ticket")
        
        let createTicketsTableQuery = """
            CREATE TABLE IF NOT EXISTS Ticket (
                ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                raffleName CHAR(255),
                ticketNumber INTERGER,
                ticketPrice INTERGER,
                purchaseTime CHAR(255),
                purchaseDate CHAR(255),
                startDate CHAR(255),
                startTime CHAR(255),
                NoTicket INTEGER,
                customerName CHAR(255),
                singleTicket CHAR(255)
        );
    """
        createTableWithQuery(createTicketsTableQuery, tableName: "Ticket")
    }
    
    func selectAllTickets() -> [Ticket] {
        
        var result = [Ticket]()
        
        let selectStatementQuery = "SELECT id, raffleName, ticketNumber, ticketPrice, purchaseTime, purchaseDate, startDate, startTime, NoTicket, customerName, singleTicket FROM Ticket;"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let ticket = Ticket(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                ticketNumber: sqlite3_column_int(row, 2),
                ticketPrice: sqlite3_column_int(row, 3),
                purchaseTime: String(cString: sqlite3_column_text(row, 4)),
                purchaseDate: String(cString: sqlite3_column_text(row, 5)),
                startDate: String(cString: sqlite3_column_text(row, 6)),
                startTime: String(cString: sqlite3_column_text(row, 7)),
                NoTicket: String(cString: sqlite3_column_text(row, 8)),
                customerName: String(cString: sqlite3_column_text(row, 9)),
                singleTicket: String(cString: sqlite3_column_text(row, 10))
            )
            result += [ticket]
        })
        return result
    }
    
    
    func insert(ticket: Ticket) {
        let insertStatementQuery = "INSERT INTO Ticket(raffleName, ticketNumber, ticketPrice, purchaseTime, purchaseDate, startDate, startTime, NoTicket, customerName, singleTicket) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string: ticket.raffleName).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, ticket.ticketNumber)
            sqlite3_bind_int(insertStatement, 3, ticket.ticketPrice)
            sqlite3_bind_text(insertStatement, 4, NSString(string: ticket.purchaseTime).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, NSString(string: ticket.purchaseDate).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, NSString(string: ticket.startDate).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, NSString(string: ticket.startTime).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8, ticket.NoTicket, -1, nil)
            sqlite3_bind_text(insertStatement, 9, NSString(string: ticket.customerName).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, NSString(string: ticket.singleTicket).utf8String, -1, nil)
        })
    }
    
    
    func selectTicketBy(raffleName: String) -> [Ticket]? {
        
        var result = [Ticket]()
        
        let selectStatementQuery = "SELECT id, raffleName, ticketNumber, ticketPrice, purchaseTime, purchaseDate, startDate, startTime, NoTicket, customerName, singleTicket FROM Ticket WHERE raffleName = '\(raffleName)';"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let ticket = Ticket(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                ticketNumber: sqlite3_column_int(row, 2),
                ticketPrice: sqlite3_column_int(row, 3),
                purchaseTime: String(cString: sqlite3_column_text(row, 4)),
                purchaseDate: String(cString: sqlite3_column_text(row, 5)),
                startDate: String(cString: sqlite3_column_text(row, 6)),
                startTime: String(cString: sqlite3_column_text(row, 7)),
                NoTicket: String(cString: sqlite3_column_text(row, 8)),
                customerName: String(cString: sqlite3_column_text(row, 9)),
                singleTicket: String(cString: sqlite3_column_text(row, 10))
            )
            result += [ticket]
        })
        return result
    }
    
    func selectTicketBy(ticketNumber: Int) -> [Ticket]? {
        
        var result = [Ticket]()
        
        let selectStatementQuery = "SELECT id, raffleName, ticketNumber, ticketPrice, purchaseTime, purchaseDate, startDate, startTime, NoTicket, customerName, singleTicket FROM Ticket WHERE ticketNumber = \(ticketNumber);"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let ticket = Ticket(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                ticketNumber: sqlite3_column_int(row, 2),
                ticketPrice: sqlite3_column_int(row, 3),
                purchaseTime: String(cString: sqlite3_column_text(row, 4)),
                purchaseDate: String(cString: sqlite3_column_text(row, 5)),
                startDate: String(cString: sqlite3_column_text(row, 6)),
                startTime: String(cString: sqlite3_column_text(row, 7)),
                NoTicket: String(cString: sqlite3_column_text(row, 8)),
                customerName: String(cString: sqlite3_column_text(row, 9)),
                singleTicket: String(cString: sqlite3_column_text(row, 10))
            )
            result += [ticket]
        })
        return result
    }
    
    func deleteByName(tableName: String, raffleName: String) {
        // prepare the statement
        let query = "DELETE FROM \(tableName) WHERE raffleName = '\(raffleName)'"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // run the query
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(tableName) table record: \(raffleName) is deleted.")
            }
        } else {
            print("\(tableName) talbe could not be deleted.")
            printCurrentSQLErrorMessage(db)
        }
        
        // Clean up
        sqlite3_finalize(statement)
    }
    

    /* --------------------------------*/
    /* ------- FOR MARGIN TABLE -------*/
    /* --------------------------------*/
    
    func createMarginTable() {
    // dropTable(tableName: "Ticket")
            
        let createMarginTableQuery = """
            CREATE TABLE IF NOT EXISTS MarginRaffle (
                ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                raffleName CHAR(255),
                prize INTEGER,
                price INTEGER,
                startDate CHAR(255),
                startTime CHAR(255),
                maxNumber INTEGER
            );
        """
        createTableWithQuery(createMarginTableQuery, tableName: "MarginRaffle")
    }
    
    func selectAllMargins() -> [MarginRaffle] {
        
        var result = [MarginRaffle]()
        
        let selectStatementQuery = "SELECT id, raffleName, prize, price, startDate, startTime, maxNumber FROM MarginRaffle;"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let marginRaffle = MarginRaffle(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                prize: sqlite3_column_int(row, 2),
                price: sqlite3_column_int(row, 3),
                startDate: String(cString: sqlite3_column_text(row, 4)),
                startTime: String(cString: sqlite3_column_text(row, 5)),
                maxNumberOfRaffle: sqlite3_column_int(row, 6)
            )
            result += [marginRaffle]
        })
        return result
    }
    
    func insert(marginRaffle: MarginRaffle) {
        let insertStatementQuery = "INSERT INTO MarginRaffle(raffleName, prize, price, startDate, startTime, maxNumber) VALUES (?, ?, ?, ?, ?, ?);"
        
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string: marginRaffle.raffleName).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, marginRaffle.prize)
            sqlite3_bind_int(insertStatement, 3, marginRaffle.price)
            sqlite3_bind_text(insertStatement, 4, NSString(string: marginRaffle.startDate).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, NSString(string: marginRaffle.startTime).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 6, marginRaffle.maxNumberOfRaffle)
        })
    }
    
    /* --------------------------------*/
    /* ------- FOR MARGIN Ticket ------*/
    /* --------------------------------*/
    
    func createMarginTicketTable() {
    // dropTable(tableName: "Ticket")
            
        let createMarginTicketQuery = """
            CREATE TABLE IF NOT EXISTS MarginTicket (
                ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                raffleName CHAR(255),
                ticketNumber INTEGER,
                purchaseTime INTEGER,
                purchaseDate INTEGER,
                startDate INTEGER,
                startTime INTEGER,
                price INTEGER,
                customerName CHAR(255)
            );
        """
        createTableWithQuery(createMarginTicketQuery, tableName: "MarginTicket")
    }
    
    func insert(marginTicket: MarginTicket) {
        let insertStatementQuery = "INSERT INTO MarginTicket(raffleName, ticketNumber, purchaseDate, purchaseTime, startDate, startTime, price, customerName) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
        
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string: marginTicket.raffleName).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, marginTicket.ticketNumber)
            sqlite3_bind_text(insertStatement, 3, NSString(string: marginTicket.purchaseDate).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, NSString(string: marginTicket.purchaseTime).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, NSString(string: marginTicket.startDate).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, NSString(string: marginTicket.startTime).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 7, marginTicket.price)
            sqlite3_bind_text(insertStatement, 8, NSString(string: marginTicket.customerName).utf8String, -1, nil)
        })
    }
    
    
    func selectAllMarginTickets() -> [MarginTicket] {
           
           var result = [MarginTicket]()
           
           let selectStatementQuery = "SELECT id, raffleName, ticketNumber, purchaseTime, purchaseDate, startDate, startTime, price, customerName FROM MarginTicket;"
           
           selectWithQuery(selectStatementQuery, eachRow: { (row) in
               let marginTicket = MarginTicket(
                   ID: sqlite3_column_int(row, 0),
                   raffleName: String(cString: sqlite3_column_text(row, 1)),
                   ticketNumber: sqlite3_column_int(row, 2),
                   purchaseTime: String(cString: sqlite3_column_text(row, 4)),
                   purchaseDate: String(cString: sqlite3_column_text(row, 3)),
                   startDate: String(cString: sqlite3_column_text(row, 5)),
                   startTime: String(cString: sqlite3_column_text(row, 6)),
                   price: sqlite3_column_int(row, 7),
                   customerName: String(cString: sqlite3_column_text(row, 8))
               )
               result += [marginTicket]
           })
           return result
    }
    
    func selectMarginTicketBy(raffleName: String) -> [MarginTicket]? {
        
        var result = [MarginTicket]()
        
        let selectStatementQuery = "SELECT id, raffleName, ticketNumber, purchaseTime, purchaseDate, startDate, startTime, price, customerName FROM MarginTicket WHERE raffleName = '\(raffleName)';"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let marginTicket = MarginTicket(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                ticketNumber: sqlite3_column_int(row, 2),
                purchaseTime: String(cString: sqlite3_column_text(row, 3)),
                purchaseDate: String(cString: sqlite3_column_text(row, 4)),
                startDate: String(cString: sqlite3_column_text(row, 5)),
                startTime: String(cString: sqlite3_column_text(row, 6)),
                price: sqlite3_column_int(row, 7),
                customerName: String(cString: sqlite3_column_text(row, 8))
            )
            result += [marginTicket]
        })
        return result
    }
    
    func selectMarginTicketBy(ticketNumber: Int32) -> [MarginTicket]? {
        
        var result = [MarginTicket]()
        
        let selectStatementQuery = "SELECT id, raffleName, ticketNumber, purchaseTime, purchaseDate, startDate, startTime, price, customerName FROM MarginTicket WHERE ticketNumber = '\(ticketNumber)';"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            let marginTicket = MarginTicket(
                ID: sqlite3_column_int(row, 0),
                raffleName: String(cString: sqlite3_column_text(row, 1)),
                ticketNumber: sqlite3_column_int(row, 2),
                purchaseTime: String(cString: sqlite3_column_text(row, 3)),
                purchaseDate: String(cString: sqlite3_column_text(row, 4)),
                startDate: String(cString: sqlite3_column_text(row, 5)),
                startTime: String(cString: sqlite3_column_text(row, 6)),
                price: sqlite3_column_int(row, 7),
                customerName: String(cString: sqlite3_column_text(row, 8))
            )
            result += [marginTicket]
        })
        return result
    }
    
}

//
//  DB.swift
//  SwiftFMDBDemo
//
//  Created by Limin Du on 11/15/14.
//  Copyright (c) 2014 GoldenFire.Do. All rights reserved.
//

import Foundation

class DB {
    
    struct Static {
        static var instance: DB?
        static var token: Int = 0
    }
    
    private static var __once: () = {
            Static.instance = DB()
            
            Static.instance?.initDatabase()
        }()
    
    class var sharedInstance: DB {
        _ = DB.__once
        
        return Static.instance!
    }
    
    class var tableName:String {
        return "table1"
    }
    
    fileprivate var db:FMDatabase?
    
    func getDatabase()->FMDatabase? {
        return db
    }
    
    fileprivate func initDatabase()->Bool {
        var result:Bool = false
        let table_name = DB.tableName
        //let documentPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        //let dbPath:String = documentPath.stringByAppendingPathComponent("demo.db")
        
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.test.abc")
        if url == nil {
            return false
        }
        
        let dbPath:String = url!.appendingPathComponent("demo.db").path
        
        let filemanager = FileManager.default
        if !filemanager.fileExists(atPath: dbPath) {
            result = filemanager.createFile(atPath: dbPath, contents: nil, attributes: nil)
            if !result {
                return false
            }
        }
        
        db = FMDatabase(path: dbPath)
        if db == nil {
            return false
        }
        
        db!.logsErrors = true
        if db!.open() {
            //db!.shouldCacheStatements()
            /*if db!.tableExists(table_name) {
                db!.executeUpdate("DROP TABLE \(table_name)", withArgumentsInArray: nil)
            }*/
            
            if !db!.tableExists(table_name) {
                let creat_table = "CREATE TABLE \(table_name) (id INTEGER PRIMARY KEY, name VARCHAR(80), description VARCHAR(80))"
                result = db!.executeUpdate(creat_table, withArgumentsIn: nil)
            }
        }
        
        print("init : \(result)")
        
        return result
    }
    
    func closeDatabase() {
        db?.close()
    }
    
    
}

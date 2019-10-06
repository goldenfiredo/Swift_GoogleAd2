
import Foundation

class DAO {
    var db:FMDatabase
    var tableName:String
    
    init () {
        db = DB.sharedInstance.getDatabase()!
        tableName = DB.tableName
    }
    
    func getRecordSet()->[Entry] {
        
        var result:[Entry] = []
        
        let sql = "SELECT * FROM \(tableName)"
        print("\(sql)")
        
        let rs = db.executeQuery(sql, withArgumentsIn: nil)
        while (rs?.next())! {
            let entry = Entry()
            let id = rs?.int(forColumn: "id")
            let name = rs?.string(forColumn: "name")
            let desc = rs?.string(forColumn: "description")
            entry.id = id!
            entry.name = name!
            entry.description = desc!
            
            print("id:\(id), name:\(name), desc:\(desc)")
            
            result.append(entry)
        }
        
        rs?.close()
        
        return result
    }
    
    func query(_ name:String, description:String)->Entry? {
        var result:Entry?
        
        let sql = "SELECT * FROM \(tableName) where name= ? and description = ?"
        let args = [name, description]
        print("\(sql)")
        
        let rs = db.executeQuery(sql, withArgumentsIn: args)
        if (rs?.next())! {
            result = Entry()
            let id = rs?.int(forColumn: "id")
            let name = rs?.string(forColumn: "name")
            let desc = rs?.string(forColumn: "description")
            result!.id = id!
            result!.name = name!
            result!.description = desc!
        }
    
        return result
    }
    
    func insert(_ name:String, description:String)->Bool {
        let sql = "INSERT INTO \(tableName) (name, description) VALUES (?, ?)"
        let args = [name, description]
        print("\(sql)")
        
        db.executeUpdate(sql, withArgumentsIn: args)
        
        if db.hadError() {
            print("error:\(db.lastErrorMessage())", terminator: "")
            return false
        }
        
        return true
    }
    
    func delete(_ name:String, description:String)->Bool {
        let sql = "DELETE FROM \(tableName) where name= ? and description = ?"
        let args = [name, description]
        print("\(sql)")
        
        db.executeUpdate(sql, withArgumentsIn: args)
        
        if db.hadError() {
            print("error:\(db.lastErrorMessage())", terminator: "")
            return false
        }
        
        return true
    }
    
    deinit {
       //DB.sharedInstance.closeDatabase()
    }
}

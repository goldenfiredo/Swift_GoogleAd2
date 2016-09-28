//
//  CoreDataDAO.swift
//
//
//  Created by Limin Du on 1/22/15.
//  Copyright (c) 2015 . All rights reserved.
//

import Foundation
import CoreData

class CoreDataDAO {
    var context:CoreDataContext!
    
    init() {
        context = CoreDataContext()
    }
    
    func getEntities()->[NSManagedObject] {
        var entity = [NSManagedObject]()
        
        let managedContext = context.managedObjectContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Person")
        
        //3
        //var error: NSError?
        
        do {
            try entity = managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            
        }
        
        /*if let results = fetchedResults {
            entity = results
        } else {
            //println("Could not fetch \(error), \(error!.userInfo)")
        }*/
        
        return entity
    }
    
    func queryEntityByName(_ name:String)->NSManagedObject?{
        var entity = [NSManagedObject]()
        
        let managedContext = context.managedObjectContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Person")
        let predicate = NSPredicate(format: "%K = %@", "name", name)
        fetchRequest.predicate = predicate
        
        //var error: NSError?
        do {
            try entity = managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            return nil
        }
        
        if entity.count == 0 {
            return nil
        }
        /*if let results = fetchedResults {
            if results.count == 0 {
                return nil
            }
            
            entity = results
        } else {
            //println("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }*/
        
        return entity[0]
    }
    
    func saveEntity(_ name:String)->NSManagedObject? {
        if let _ = queryEntityByName(name) {
            return nil
        }
        
        let managedContext = context.managedObjectContext!
        
        let entity =  NSEntityDescription.entity(forEntityName: "Person", in:managedContext)
        
        let person = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        person.setValue(name, forKey: "name")
        
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
            return nil
        }
        
        return person
    }
    
    func deleteEntity(_ name:String)->Bool {
        let managedContext = context.managedObjectContext!
        
        let entityToDelete = queryEntityByName(name)
        if let entity = entityToDelete {
            managedContext.delete(entity)
            
            do {
                try managedContext.save()
                return true
            } catch {
                return false
            }
            /*var error:NSError?
            if managedContext.save() != true {
                print("Delete error: " + error!.localizedDescription)
                return false
            }
            
            return true*/
        }
        
        return false
    }
    
    func saveContext() {
        context.saveContext()
    }
}

//
//  DBUtils.swift
//  Image Machine
//
//  Created by odikk on 22/07/21.
//

import Foundation
import CoreData
import UIKit

class DBUtils {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //    func taskContext() -> NSManagedObjectContext {
    //        let persistentContainer: NSPersistentContainer = {
    //            let container = NSPersistentContainer(name: "Machine")
    //            container.loadPersistentStores { storeDesription, error in
    //                guard error == nil else {
    //                    fatalError("Unresolved error \(error!)")
    //                }
    //            }
    //            container.viewContext.automaticallyMergesChangesFromParent = false
    //            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    //            container.viewContext.shouldDeleteInaccessibleFaults = true
    //            container.viewContext.undoManager = nil
    //
    //            return container
    //        }()
    //        let taskContext = persistentContainer.newBackgroundContext()
    //        taskContext.undoManager = nil
    //
    //        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    //        return taskContext
    //    }
    
    func readDataByID(id: Int, completion: @escaping(_ machine: MachineEntity)->()) {
        let request: NSFetchRequest<MachineEntity> = MachineEntity.fetchRequest()
        do {
            if (try context.fetch(request).first) != nil {
                let machine = MachineEntity(context: context)
                completion(machine)
            }
        } catch let error as NSError {
            print("Error : \(error)")
        }
    }
    
    func getAllMachine() -> [MachineEntity]?{
        let request: NSFetchRequest<MachineEntity> = MachineEntity.fetchRequest()
        do {
            let machine = try context.fetch(request)
            return machine
        } catch let err {
            print(err)
            return nil
        }
    }
    
    func isIDExist(id: Int) -> Bool{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MachineEntity")
        fetchRequest.predicate = NSPredicate(format: "machineID == \(id)")
        do{
            let dbResult = try context.count(for: fetchRequest)
            if dbResult < 1 {
                return false
            } else {
                return true
            }
            
        } catch let err {
            print(err)
            return false
        }
    }
    
    func generateID() -> Int {
        var randNumber = Utils().generateRandomId()
        if isIDExist(id: randNumber) {
            randNumber = Utils().generateRandomId()
        }
        return randNumber
    }
    
    func saveImageData(images: ImageEntity, completion: @escaping() -> ()){
        if let entity = NSEntityDescription.entity(forEntityName: "ImageEntity", in: context){
            let imageEntity = NSManagedObject(entity: entity, insertInto: context)
            imageEntity.setValue(images.machineId, forKey: "machineId")
            imageEntity.setValue(images.machineImage, forKey: "machineImage")
        }
        do {
            try context.save()
            print("saving image success...")
            completion()
        } catch let err {
            print(err)
        }
    }
  
    func saveMachineData(name: String, type: String, lastMaintenance: Date, image: Data?, completion: @escaping()->()){
        if let entity = NSEntityDescription.entity(forEntityName: "MachineEntity", in: context){
            let machineEntity = NSManagedObject(entity: entity, insertInto: context)
            let id = generateID()
            machineEntity.setValue(id, forKey: "machineID")
            machineEntity.setValue(name, forKey: "machineName")
            machineEntity.setValue(type, forKey: "machineType")
            machineEntity.setValue(id, forKey: "machineQRCodeNumber")
            machineEntity.setValue(lastMaintenance, forKey: "lastMaintenance")
            machineEntity.setValue(image, forKey: "image")
            print("machine: \(machineEntity)")
        }
        do {
            try context.save()
            print("machine data saved successfully...")
            completion()
        } catch let err {
            print(err)
        }
    }
    
    func updateMachineData(id: Int, name: String, type: String, codeNumber: Int, lastMaintenance: Date, image: Data?, completion: @escaping()->()){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MachineEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "machineID == \(id)")
        do {
            let machineObject = try context.fetch(fetchRequest).first as! NSManagedObject
            machineObject.setValue(id, forKey: "machineID")
            machineObject.setValue(name, forKey: "machineName")
            machineObject.setValue(type, forKey: "machineType")
            machineObject.setValue(codeNumber, forKey: "machineQRCodeNumber")
            machineObject.setValue(lastMaintenance, forKey: "lastMaintenance")
            machineObject.setValue(image, forKey: "image")
            try context.save()
            completion()
            print("updated successfully...")
        } catch let err {
            print(err)
        }
    }
    
    func deleteMachineData(id: Int){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "MachineEntity")
        fetchRequest.predicate = NSPredicate(format: "machineID == \(id)")
        do {
            let machineObject = try context.fetch(fetchRequest).first as! NSManagedObject
            context.delete(machineObject)
            try context.save()
        } catch let err {
            print(err)
        }
    }
    
    func coreDataObjectFromImages(images: [UIImage]) -> Data? {
        let dataArray = NSMutableArray()
        
        for img in images {
            if let data = img.pngData() {
                dataArray.add(data)
            }
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
    }
    
    func imagesFromCoreData(object: Data?) -> [UIImage]? {
        var retVal = [UIImage]()
        
        guard let object = object else { return nil }
        if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: object) {
            for data in dataArray {
                if let data = data as? Data, let image = UIImage(data: data) {
                    retVal.append(image)
                }
            }
        }
        
        return retVal
    }
}

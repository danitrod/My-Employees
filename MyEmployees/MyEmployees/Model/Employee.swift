
import Foundation
import UIKit
import os.log

class Employee: NSObject, NSCoding {
    
    //MARK: Properties
    var id: Int
    var name: String
    var photo: UIImage?
    var rg: String
    var departmentId: Int
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("employees")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let id = "id"
        static let photo = "photo"
        static let rg = "rg"
        static let departmentId = "departmentId"
    }
    
    //Mark: Initialization
    init?(name: String, photo: UIImage?, rg: String, departmentId: Int, id: Int, hasExistingId: Bool) {
        
        // Fails init if name or rg is empty
        if name.isEmpty || rg.isEmpty {
            fatalError("Creating an Employee with no name or rg.")
            return nil
        }
        
        self.name = name
        self.photo = photo ?? nil
        self.rg = rg
        self.departmentId = departmentId
        
        if hasExistingId {
            self.id = id
        }
        else {
            //Setting id with department id before number
            let s = "\(departmentId)\(id)"
            self.id = Int(s)!
        }
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(id, forKey: PropertyKey.id)
        aCoder.encode(rg, forKey: PropertyKey.rg)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(departmentId, forKey: PropertyKey.departmentId)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name, id and initials are required. If we cannot decode a name, id or initials string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Department object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let id = aDecoder.decodeInteger(forKey: PropertyKey.id) 
        
        guard let rg = aDecoder.decodeObject(forKey: PropertyKey.rg) as? String else {
            os_log("Unable to decode the initials for a Department object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let departmentId = aDecoder.decodeInteger(forKey: PropertyKey.departmentId)
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rg: rg, departmentId: departmentId, id: id, hasExistingId: true)
        
    }
}

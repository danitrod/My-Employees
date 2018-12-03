
import Foundation
import os.log


class Department: NSObject, NSCoding {
    
    //MARK: Properties
    var id: Int
    var name: String
    var initials: String
    var numberOfEmployees:Int?
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("departments")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let id = "id"
        static let initials = "initials"
        static let numberOfEmployees = "numberOfEmployees"
    }
    
    //MARK: Creating unique ID
    private static var identifierFactory: Int {
        get{
            //retorna último id armazenado
            return UserDefaults.standard.integer(forKey: "id")
        }
        set{
            //cada vez que essa variável recebe um novo valor, ele é armazenado no UserDefaults
            UserDefaults.standard.set(newValue, forKey: "id")
        }
    }
    
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    //MARK: Initialization
    init?(name: String, initials: String, id: Int?, numberOfEmployees: Int?) {
        
        // Fails init if name or initials is empty
        if name.isEmpty || initials.isEmpty {
            fatalError("Creating a Department with no name or initials.")
            return nil
        }
        
        self.name = name
        self.initials = initials
        self.numberOfEmployees = numberOfEmployees ?? nil
        
        // Generates new id if id is nil
        self.id = id ?? Department.getUniqueIdentifier()
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(id, forKey: PropertyKey.id)
        aCoder.encode(initials, forKey: PropertyKey.initials)
        aCoder.encode(numberOfEmployees, forKey: PropertyKey.numberOfEmployees)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name, id and initials are required. If we cannot decode a name, id or initials string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Department object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let id = aDecoder.decodeInteger(forKey: PropertyKey.id)
        
        guard let initials = aDecoder.decodeObject(forKey: PropertyKey.initials) as? String else {
            os_log("Unable to decode the initials for a Department object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let numberOfEmployees = aDecoder.decodeObject(forKey: PropertyKey.numberOfEmployees) as? Int
        
        // Must call designated initializer.
        self.init(name: name, initials: initials, id: id, numberOfEmployees: numberOfEmployees)
        
    }
}


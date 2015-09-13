import Foundation
import CoreData

class Cart: NSManagedObject {
    
    static let EntityName = "Cart"
    
    @NSManaged var code: String
    @NSManaged var status: String
    @NSManaged var date: NSDate
    @NSManaged var entries: NSOrderedSet
    
    var cartStatus: CartStatus {
        get { return CartStatus(rawValue: self.status) ?? .SHOPPING }
        set { self.status = newValue.rawValue }
    }
    
    func getCount() -> Int {
        return entries.count
    }
    
    func getEntry(index: Int) -> CartEntry {
        var items = self.mutableOrderedSetValueForKey("entries")
        return items[index] as! CartEntry
    }
    
    func addEntry(entry: CartEntry) {
        var items = self.mutableOrderedSetValueForKey("entries")
        items.addObject(entry)
    }
    
    func removeEntry(index: Int) {
        var items = self.mutableOrderedSetValueForKey("entries")
        items.removeObjectAtIndex(index)
    }
    
    func findEntry(id: String) -> CartEntry? {
        for entry in (self.mutableOrderedSetValueForKey("entries").array as! [CartEntry]) {
            if (entry.product.id == id) {
                return entry
            }
        }
        return nil
    }
    
    func serialize() -> NSDictionary {
        
        var items = [NSDictionary]()
        for entry in entries {
            items.append(entry.serialize())
        }
        
        let cart = [
            "cartCode": code,
            "items": items,
            "status": status,
            "pushToken" : PushToken.token,
            "platformType" : PlatformType.APPLE.rawValue
        ]
        
        Debug.instance.log("Serialized cart is \n \(cart)")
        return cart
        
    }
    
}

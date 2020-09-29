import UIKit
import RealmSwift
import Foundation
 
class Place: Object {
 
    @objc dynamic var id: String? = nil
    @objc dynamic var name: String? = nil
    @objc dynamic var address: String? = nil
    @objc dynamic var latitude: String? = nil
    @objc dynamic var longitude: String? = nil
    @objc dynamic var identifier: String? = nil
    @objc dynamic var note: String? = nil
        
}

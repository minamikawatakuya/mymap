
import UIKit
import RealmSwift
import MapKit

class PlaceCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var identifierField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func pushUpdate(_ sender: Any) {
        let realm = try! Realm()
        let places = realm.objects(Place.self).filter("id == '"+self.idLabel.text!+"'")
        
        places.forEach { place in
            let tmpName = self.nameField.text!
            let tmpAddress = self.addressField.text!
            let tmpIdentifier = self.identifierField.text!
            CLGeocoder().geocodeAddressString(self.addressField.text!) { placemarks, error in
                
                var tmpLat = ""
                var tmpLon = ""
                if let lat = placemarks?.first?.location?.coordinate.latitude {
                    tmpLat = String(lat)
                }
                if let lng = placemarks?.first?.location?.coordinate.longitude {
                    tmpLon = String(lng)
                }
                
                try! realm.write() {
                    place.name = tmpName
                    place.address = tmpAddress
                    place.identifier = tmpIdentifier
                    place.latitude = tmpLat
                    place.longitude = tmpLon
                }

            }
            
        }
        
    }
    
}

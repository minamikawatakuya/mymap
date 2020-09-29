//
//  PlaceCell.swift
//  mymap
//
//  Created by minamikawa on 2020/09/29.
//  Copyright © 2020 minamikawa. All rights reserved.
//

import UIKit
import RealmSwift

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
            try! realm.write() {
                place.name = self.nameField.text!
                place.address = self.addressField.text!
                place.identifier = self.identifierField.text!
            }
        }
    }
    
}

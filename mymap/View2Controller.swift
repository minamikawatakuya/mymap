
import UIKit
import RealmSwift

class View2Controller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var identifierField: UITextField!
    
    @IBOutlet weak var table: UITableView!
    
    // モデルクラスを使用し、取得データを格納する変数を作成
    var tableCells: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func pushRegist(_ sender: Any) {
    }
    
    // cellの数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableCells.count
    }

    // cellに値を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell",
        for: indexPath) as! PlaceCell
        
        let tmpCell: Place = self.tableCells[(indexPath as NSIndexPath).row];
        
        cell.idField.text = tmpCell.id
        cell.nameField.text = tmpCell.name
        cell.addressField.text = tmpCell.address
        cell.identifierField.text = tmpCell.identifier
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 225
    }
    
}

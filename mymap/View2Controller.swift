
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
        
        // Interface Builderのファイルを読み込む
        let nib = UINib(nibName: "PlaceCell", bundle: nil)
        
        // UITableViewに登録する。NewsCellを使用するという宣言
        table.register(nib, forCellReuseIdentifier: "PlaceCell")

        // Realmインスタンス取得
        let realm = try! Realm()
         
        // データ全権取得
        self.tableCells = realm.objects(Place.self)

    }
    
    @IBAction func pushRegist(_ sender: Any) {
        
        let idvalue = self.tableCells.count + 1;
        
        // モデルクラスのインスタンスを取得
        let MemoInstance:Place = Place()
         
        // テキスト入力値をインスタンスに詰める
        //MemoInstance.id = self.idField.text
        MemoInstance.id = String(idvalue)
        MemoInstance.name = self.nameField.text
        MemoInstance.address = self.addressField.text
        MemoInstance.identifier = self.identifierField.text
         
        // Realmインスタンス取得
        let realm = try! Realm()
         
        // DB登録処理
        try! realm.write {
            realm.add(MemoInstance)
        }
         
        // テーブル再読み込み
        self.table.reloadData()
        
        self.idField.text = "";
        self.nameField.text = "";
        self.addressField.text = "";
        self.identifierField.text = "";
        
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
        
        cell.idLabel.text = tmpCell.id
        cell.nameField.text = tmpCell.name
        cell.addressField.text = tmpCell.address
        cell.identifierField.text = tmpCell.identifier
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 225
    }
    
}

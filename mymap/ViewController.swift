
import UIKit
import CoreLocation
import MapKit
import UserNotifications
import RealmSwift

class ViewController: UIViewController, CLLocationManagerDelegate,
UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var myLock = NSLock()
    let goldenRatio = 1.618
    
    var shopList : [
        (
        name:String , address:String, latitude:Double, longitude:Double,
        note:String , identifier:String
        )
    ] = []
    
    // モデルクラスを使用し、取得データを格納する変数を作成
    var tableCells: Results<Place>!
    
    var notice_name:String = ""
    var notice_note:String = ""
    var pin_latitude:String = "0.0"
    var pin_longitude:String = "0.0"
    
    var pins: [String: MKPointAnnotation] = [:]
    
    var timer = Timer()
    
    //processing count
    var count = 0
    
    var latitudeNow:Double = 0.0
    var longitudeNow:Double = 0.0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager!

    @IBAction func clickZoomin(_ sender: Any) {
        print("[DBG]clickZoomin")
        myLock.lock()
        if (0.005 < mapView.region.span.latitudeDelta / goldenRatio) {
            print("[DBG]latitudeDelta-1 : " + mapView.region.span.latitudeDelta.description)
            var regionSpan:MKCoordinateSpan = MKCoordinateSpan()
            regionSpan.latitudeDelta = mapView.region.span.latitudeDelta / goldenRatio
            mapView.region.span = regionSpan
            print("[DBG]latitudeDelta-2 : " + mapView.region.span.latitudeDelta.description)
        }
        myLock.unlock()
    }
    
    @IBAction func clickZoomout(_ sender: Any) {
        print("[DBG]clickZoomout")
        myLock.lock()
        if (mapView.region.span.latitudeDelta * goldenRatio < 150.0) {
            print("[DBG]latitudeDelta-1 : " + mapView.region.span.latitudeDelta.description)
            var regionSpan:MKCoordinateSpan = MKCoordinateSpan()
            regionSpan.latitudeDelta = mapView.region.span.latitudeDelta * goldenRatio
            mapView.region.span = regionSpan
            print("[DBG]latitudeDelta-2 : " + mapView.region.span.latitudeDelta.description)
        }
        myLock.unlock()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()  // 変数を初期化
        locationManager.delegate = self  // delegateとしてself(自インスタンス)を設定

        locationManager.startUpdatingLocation()  // 位置情報更新を指示
        locationManager.requestWhenInUseAuthorization()  // 位置情報取得の許可を得る
        
        mapView.showsUserLocation = true
        
        // 拡大表示
        var cr:MKCoordinateRegion = mapView.region
        cr.span.latitudeDelta = 0.005
        cr.span.longitudeDelta = 0.005
        mapView.setRegion(cr, animated: true)
        
        collectionView.register(UINib(nibName: "shopCell", bundle: nil), forCellWithReuseIdentifier: "shopCell")
        
        let tblBackColor: UIColor = UIColor.clear
        collectionView.backgroundColor = tblBackColor
        
        // Realmインスタンス取得
        let realm = try! Realm()
         
        // データ全権取得
        self.tableCells = realm.objects(Place.self)
        
        //doGeofenceStart()
        
        //for i in 0..<self.tableCells.count{
        
        
        
        
        
        //timer処理
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (timer) in
            
            // 一覧から削除
            var tmpList : [
                (
                name:String , address:String, latitude:Double, longitude:Double,
                note:String , identifier:String
                )
            ] = []
            
            self.count += 1
            //self.count値をコンソールへ出力
            print(self.count)
            print(self.latitudeNow)
            print(self.longitudeNow)
            //print(self.tableCells.count)
            var dist = ""
            var distInt:Int = 0
            for i in 0..<self.tableCells.count{
                
                print(self.tableCells[i].name!)
                print(self.tableCells[i].latitude!)
                print(self.tableCells[i].longitude!)
                
                let tmpLatPlace:Double = atof(self.tableCells[i].latitude)
                let tmpLonPlace:Double = atof(self.tableCells[i].longitude)
                
                dist = self.getDistance(
                    latNow:self.latitudeNow,
                    lonNow:self.longitudeNow,
                    latPlace:tmpLatPlace,
                    lonPlace:tmpLonPlace
                )
                print(dist)
                distInt = Int(dist) ?? 0
                
                if( distInt < 200 ){
                    tmpList.append( (
                        name : self.tableCells[i].name! ,
                        address : self.tableCells[i].address!,
                        latitude : tmpLatPlace,
                        longitude : tmpLonPlace,
                        note : self.tableCells[i].address!,
                        identifier : self.tableCells[i].identifier!
                    ) )
                    
                }
                
            }
            
            self.shopList = tmpList
            self.collectionView.reloadData()
            
            
            
            
            
            
            
        })
        
    }
    
    func getDistance(latNow:Double,lonNow:Double,latPlace:Double,lonPlace:Double)-> String{
        //let 現在地の緯度: Double = Double(latNow)
        //let 現在地の経度: Double = Double(lonNow)
        //let 行き先の緯度: Double = Double(latPlace)
        //let 行き先の経度: Double = Double(lonPlace)
        let nowInfo:CLLocation = CLLocation(latitude: latNow, longitude: lonNow)
        let placeInfo:CLLocation = CLLocation(latitude: latPlace, longitude: lonPlace)
        let dist = placeInfo.distance(from: nowInfo)
        let distInt = Int(dist)
        return String(distInt)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shopCell", for: indexPath) as! shopCell
        
        cell.nameLabel.text = shopList[indexPath.row].name
        cell.noteLabel.text = shopList[indexPath.row].note
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 120)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        let longitude = (locations.last?.coordinate.longitude.description)!
        let latitude = (locations.last?.coordinate.latitude.description)!
        print("[DBG]longitude : " + longitude)
        print("[DBG]latitude : " + latitude)
        
        latitudeNow = Double(latitude) ?? 0.0
        longitudeNow = Double(longitude) ?? 0.0
        
        myLock.lock()
        mapView.setCenter((locations.last?.coordinate)!, animated: true)
        myLock.unlock()
    }
    
    func doGeofenceStart() {
        // モニタリング開始：このファンクションは適宜ボタンアクションなどから呼ぶ様にする。
        self.startGeofenceMonitering()
    }
    
    func startGeofenceMonitering() {
        
        // モニタリングしたい場所の緯度経度を設定
        var moniteringCordinate = CLLocationCoordinate2DMake(35.776332, 139.301929) // 小作駅の緯度経度
        // モニタリングしたい領域を作成
        var moniteringRegion = CLCircularRegion.init(center: moniteringCordinate, radius: 400.0, identifier: "OzakuEki")
        
        for i in 0..<self.tableCells.count{
            
            let tmpCell: Place = self.tableCells[i]
            var tmpLat = 0.0
            var tmpLng = 0.0
            
            tmpLat = Double(tmpCell.latitude!) ?? 0.0
            tmpLng = Double(tmpCell.longitude!) ?? 0.0
            
            moniteringCordinate = CLLocationCoordinate2DMake(tmpLat, tmpLng)
            moniteringRegion = CLCircularRegion.init(center: moniteringCordinate, radius: 100.0, identifier: tmpCell.identifier!)
            locationManager.startMonitoring(for: moniteringRegion)
            
        }
        
    }
    
    // 位置情報取得認可
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("ユーザー認証未選択")
            break
        case .denied:
            print("ユーザーが位置情報取得を拒否しています。")
            //位置情報取得を促す処理を追記
            break
        case .restricted:
            print("位置情報サービスを利用できません")
            break
        case .authorizedWhenInUse:
            print("アプリケーション起動時のみ、位置情報の取得を許可されています。")
            break
        case .authorizedAlways:
            print("このアプリケーションは常時、位置情報の取得を許可されています。")
            break
        @unknown default:
            fatalError()
        }
    }
    
    // ジオフェンスモニタリング

    // モニタリング開始成功時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        let strTmp = "モニタリング開始"+region.identifier
        print(strTmp)
    }

    // モニタリングに失敗したときに呼ばれる
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        let strTmp = "モニタリングに失敗しました。"+region!.identifier
        print(strTmp)
    }

    // ジオフェンス領域に侵入時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let strTmp = "設定したジオフェンスに入りました。"+region.identifier
        print(strTmp)
        
        var placeIdentifier = ""
        let realm = try! Realm()
        let places = realm.objects(Place.self).filter("identifier like '"+region.identifier+"'")
        places.forEach { place in
            notice_name = place.name!
            notice_note = place.address!
            placeIdentifier = place.identifier!
            pin_latitude = place.latitude!
            pin_longitude = place.longitude!
        }
        
        //doLocalNotification(name:notice_name,note:notice_note)
        
        /*
        shopList.append( (
            name : notice_name ,
            address : "",
            latitude : 0.0,
            longitude : 0.0,
            note : notice_note,
            identifier : placeIdentifier
        ) )
        collectionView.reloadData()
 */
        
        // ピンを立てる
        dispPin(lat:pin_latitude,lon:pin_longitude,title:notice_name,subtitle:notice_note,identifier:placeIdentifier)
        
    }

    // ジオフェンス領域から出たときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let strTmp = "設定したジオフェンスから出ました。"+region.identifier
        print(strTmp)
        
        // 一覧から削除
        /*
        var tmpList : [
            (
            name:String , address:String, latitude:Double, longitude:Double,
            note:String , identifier:String
            )
        ] = []
        for i in 0..<shopList.count{
            if( shopList[i].identifier != region.identifier ){
                tmpList.append( (
                    name : shopList[i].name ,
                    address : shopList[i].address,
                    latitude : shopList[i].latitude,
                    longitude : shopList[i].longitude,
                    note : shopList[i].note,
                    identifier : shopList[i].identifier
                ) )
            }
        }
        shopList = tmpList
        collectionView.reloadData()
 */
        
        // PINを削除
        deletePin(identifier:region.identifier)
        
    }

    // ジオフェンスの情報が取得できないときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let strTmp = "モニタリングエラーです。"
        print(strTmp)
    }
    
    // ローカル通知の実行
    func doLocalNotification(name:String,note:String){
        
        // ローカル通知のの内容
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = name
        content.body = note
        
        // タイマーの時間（秒）をセット
        let timer = 1
        // ローカル通知リクエストを作成
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timer), repeats: false)
        let identifier = NSUUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func dispPin(lat:String,lon:String,title:String,subtitle:String,identifier:String){
        
        // 経度、緯度
        let myLatitude: CLLocationDegrees = Double(lat) ?? 0.0
        let myLongitude: CLLocationDegrees = Double(lon) ?? 0.0

        // 中心点
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLatitude, myLongitude)
        
        // ピンを生成
        pins[identifier] = MKPointAnnotation()

        // 座標を設定
        pins[identifier]?.coordinate = center

        // タイトルを設定
        pins[identifier]?.title = title

        // サブタイトルを設定
        pins[identifier]?.subtitle = subtitle

        // MapViewにピンを追加
        mapView.addAnnotation(pins[identifier]!)
        
    }
    
    func deletePin(identifier:String){
        if( pins[identifier] != nil ){
            mapView.removeAnnotation(pins[identifier]!)
        }
    }

}


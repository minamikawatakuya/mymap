//
//  ViewController.swift
//  mymap
//
//  Created by minamikawa on 2020/09/25.
//  Copyright © 2020 minamikawa. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UserNotifications

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
    
    var notice_name:String = "hoge"
    var notice_note:String = "hoge"
    
    
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
            //regionSpan.latitudeDelta = mapView.region.span.longitudeDelta * GoldenRatio
            mapView.region.span = regionSpan
            print("[DBG]latitudeDelta-2 : " + mapView.region.span.latitudeDelta.description)
        }
        myLock.unlock()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopList.append( (
            name : "青梅末広郵便局" ,
            address : "東京都青梅市末広町２丁目２−１",
            latitude : 35.778773,
            longitude : 139.306377,
            note : "ノートノートノートノートノートノートノートノートノートノート",
            identifier : "OmeSuehiroPostOffice"
        ) )
        shopList.append( (
            name : "スーパーオザム 末広店" ,
            address : "東京都青梅市新町３丁目１５−１",
            latitude : 35.779938,
            longitude : 139.304928,
            note : "ノートノートノートノートノートノートノートノートノートノート",
            identifier : "SuperOZAMSuehiro"
        ) )
        shopList.append( (
            name : "ゲオ青梅新町店" ,
            address : "東京都青梅市新町５丁目 4番3号",
            latitude : 35.786547,
            longitude : 139.307555,
            note : "ノートノートノートノートノートノートノートノートノートノート",
            identifier : "GeoOumeshinmachi"
        ) )
        
        locationManager = CLLocationManager()  // 変数を初期化
        locationManager.delegate = self  // delegateとしてself(自インスタンス)を設定

        locationManager.startUpdatingLocation()  // 位置情報更新を指示
        locationManager.requestWhenInUseAuthorization()  // 位置情報取得の許可を得る
        
        mapView.showsUserLocation = true
        
        collectionView.register(UINib(nibName: "shopCell", bundle: nil), forCellWithReuseIdentifier: "shopCell")
        
        doGeofenceStart()
        
        let tblBackColor: UIColor = UIColor.clear
        collectionView.backgroundColor = tblBackColor
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopList.count
        //return 1
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
        
        for i in 0..<shopList.count{
            
            // モニタリングしたい場所の緯度経度を設定
            moniteringCordinate = CLLocationCoordinate2DMake(shopList[i].latitude, shopList[i].longitude)
            
            // モニタリングしたい領域を作成
            moniteringRegion = CLCircularRegion.init(center: moniteringCordinate, radius: 100.0, identifier: shopList[i].identifier)
            
            // モニタリング開始
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
        
        if( region.identifier == "OmeSuehiroPostOffice" ){
            
            notice_name = "青梅末広郵便局"
            notice_note = "ノートノートノートノートノートノートノートノートノートノートノートノートノート"
            
        }else if( region.identifier == "SuperOZAMSuehiro" ){
            
            notice_name = "スーパーオザム 末広店"
            notice_note = "ノートノートノートノートノートノートノートノートノートノートノートノートノート"
            
        }else if( region.identifier == "GeoOumeshinmachi" ){
            
            notice_name = "ゲオ青梅新町店"
            notice_note = "ノートノートノートノートノートノートノートノートノートノートノートノートノート"
            
        }
        
        doLocalNotification(name:notice_name,note:notice_note)
    }

    // ジオフェンス領域から出たときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let strTmp = "設定したジオフェンスから出ました。"+region.identifier
        print(strTmp)
    }

    // ジオフェンスの情報が取得できないときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let strTmp = "モニタリングエラーです。"
        print(strTmp)
    }
    
    // ローカル通知の実行
    func doLocalNotification(name:String,note:String){
        
        //print("doLocalNotification")
        
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


}


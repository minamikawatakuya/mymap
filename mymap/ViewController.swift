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

class ViewController: UIViewController, CLLocationManagerDelegate {
    var myLock = NSLock()
    let goldenRatio = 1.618
    
    var shopList : [
        (
        name:String , address:String, latitude:Double, longitude:Double,
        coupon_title:String, coupon_period:String, coupon_message:String,
        identifier:String
        )
    ] = []
    
    var notice_title:String = "hoge"
    var notice_subtitle:String = "hoge"
    var notice_body:String = "hoge"
    
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
            coupon_title : "郵送料10%引き",
            coupon_period : "8/1(土)〜8/31(月)",
            coupon_message : "クーポンメッセージ、クーポンメッセージ、クーポンメッセージ、クーポンメッセージ",
            identifier : "OmeSuehiroPostOffice"
        ) )
        shopList.append( (
            name : "スーパーオザム 末広店" ,
            address : "東京都青梅市新町３丁目１５−１",
            latitude : 35.779938,
            longitude : 139.304928,
            coupon_title : "惣菜全品20%オフ",
            coupon_period : "9/1(土)〜9/30(月)",
            coupon_message : "お一人様三品まで。お一人様三品まで。お一人様三品まで。。お一人様三品まで。",
            identifier : "SuperOZAMSuehiro"
        ) )
        shopList.append( (
            name : "ゲオ青梅新町店" ,
            address : "東京都青梅市新町５丁目 4番3号",
            latitude : 35.786547,
            longitude : 139.307555,
            coupon_title : "準新作DVDレンタル1枚100円",
            coupon_period : "10/1(土)〜10/31(月)",
            coupon_message : "10枚以上レンタルで14日間レンタルできます。10枚以上レンタルで14日間レンタルできます。",
            identifier : "GeoOumeshinmachi"
        ) )
        
        locationManager = CLLocationManager()  // 変数を初期化
        locationManager.delegate = self  // delegateとしてself(自インスタンス)を設定

        locationManager.startUpdatingLocation()  // 位置情報更新を指示
        locationManager.requestWhenInUseAuthorization()  // 位置情報取得の許可を得る
        
        mapView.showsUserLocation = true
        
        doGeofenceStart()
        
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
            
            notice_title = "青梅末広郵便局"
            notice_subtitle = "郵送料10%引き"
            notice_body = "8/1(土)〜8/31(月)\n"+"クーポンメッセージ、クーポンメッセージ、クーポンメッセージ"
            
        }else if( region.identifier == "SuperOZAMSuehiro" ){
            
            notice_title = "スーパーオザム 末広店"
            notice_subtitle = "惣菜全品20%オフ"
            notice_body = "9/1(土)〜9/30(月)\n"+"お一人様三品まで。お一人様三品まで。お一人様三品まで。。お一人様三品まで。"
            
        }else if( region.identifier == "GeoOumeshinmachi" ){
            
            notice_title = "ゲオ青梅新町店"
            notice_subtitle = "準新作DVDレンタル1枚100円"
            notice_body = "10/1(土)〜10/31(月)\n"+"10枚以上レンタルで14日間レンタルできます。10枚以上レンタルで14日間レンタルできます。"
            
        }
        
        doLocalNotification(title:notice_title,subtitle:notice_subtitle,body:notice_body)
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
    func doLocalNotification(title:String,subtitle:String,body:String){
        
        //print("doLocalNotification")
        
        // ローカル通知のの内容
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = title
        content.subtitle = subtitle
        content.body = body
        
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

